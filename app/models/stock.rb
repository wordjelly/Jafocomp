require 'elasticsearch/persistence/model'

## routes like
## indicators/stochastic_oscillator_indicator
## stocks/Asian%10Paints/indicators
## stocks/ABC/combinations/XYZ/indicators/

## for a given stock (with or without combining factors)
## stocks/ABC
## it will show -> top 5 hits, and combination card hits.
## if you click on an exchange -> will show top 5 hits, for all stocks in that exchange.
## if you click on a combination card -> you can skip or paginate, by simple url query parameters.
## if you click on an indicator -> it is like an exchange, we need combinations for all entities, impacted by those indicators.

## how to compare against stocks of only a particular exchange, will have to be able to filter like that somehow.


## so we need these nested urls.
## so we can have and_stock.
class Stock

	include Elasticsearch::Persistence::Model
	include Concerns::EsBulkIndexConcern
	include Concerns::Stock::IndividualConcern
	include Concerns::Stock::CombinationConcern
	include Concerns::BackgroundJobConcern


	INFORMATION_TYPE_ENTITY = "entity"
	SINGLE = 0
	COMBINATION = 1


	attribute :stock_name, String, mapping: {type: 'keyword'}

	attribute :stock_description, Integer, mapping: {type: 'keyword'}

	attribute :stock_link, String, mapping: {type: 'keyword'}

	attribute :stock_top_results, Array[Hash], mapping: {type: 'nested'}

	attribute :stock_result_type, Integer, default: SINGLE, mapping: {type: 'integer'}

	attribute :stock_impacted, String, mapping: {type: 'keyword'}

	attribute :stock_primary, String, mapping: {type: 'keyword'}
	## the exchanges, are the exchanges of the two entities in the complex.
	attribute :stock_exchanges, Array

	index_name "frontend"
	document_type "doc"

	attr_accessor :trigger_update
	attr_accessor :stock_id
	attr_accessor :indicator_id
	attr_accessor :exchange_id
	attr_accessor :skip



	#############################################################
	##
	##
	## CALLBACKS
	##
	##
	#############################################################
	after_save do |document|
		puts "document trigger update is :#{document.trigger_update}"
		ScheduleJob.perform_later([self.id.to_s,"Stock","update"]) unless document.trigger_update.blank?
	end
	
	#############################################################
	##
	##
	## expected to be executed from a background job.
	##
	##
	#############################################################
	def update
		update_top_results
		update_combinations
		self.trigger_update = false
		self.save
	end

	def set_name_description_link
		if info = get_information
			self.stock_name = info._source.information_name
			self.stock_description = info._source.information_description
			self.stock_link = info._source.information_link
		end
	end	

	def get_information
		query = {
			bool: {
				must: [
					{
						term: {
							information_type: INFORMATION_TYPE_ENTITY
						}
					},
					{
						term: {
							information_id: self.id.to_s
						}
					}
				]
			}
		}	
		puts query.to_s

		response = Hashie::Mash.new Stock.gateway.client.search :body => {:size => 1, :query => query}, :index => "correlations", :type => "result"
		
		puts "Response is:"
		puts response.to_s

		info = nil

		if response.hits.hits.size > 0
			info = response.hits.hits.first
		end

		info

	end

	############################################################
	##
	##
	## CLASS METHODS.
	##
	##
	############################################################


	## @params[String] id : the id of the stock
	## @return[Stock] e : either the stock if it exists, otherwise a new instance of an stock, with the provided id. 
	def self.find_or_initialize(args={})
		e = nil
		return Stock.new(args) if args[:id].blank?
		begin
			e = Stock.gateway.client.get :id => args[:id], :index => index_name, :type => document_type
			e.attributes.merge!(args)
		rescue Elasticsearch::Transport::Transport::Errors::NotFound
			puts "rescuing."
			e = Stock.new(args)
			puts "args are :#{args}"
			e.set_name_description_link
		end
		puts e.trigger_update.to_s
		e
	end

	def self.permitted_params
		[
			:id,
			{:stock => [:trigger_update, :stock_id, :indicator_id, :exchange_id]}
		]
	end


end