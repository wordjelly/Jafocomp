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
	include Concerns::Stock::EntityConcern

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
		puts "Came to find or initialize with args: #{args}"
		e = nil
		cls = args.delete(:class_name) || "Stock"
		cls = cls.constantize
		return cls.new(args) if ((args[:id].blank?))
		begin
			puts index_name
			puts document_type

			query = {
				bool: {
					should: [
						{
							ids: {
								values: [args[:id]]
							}
						},
						{
							term: {
								stock_name: args[:id]
							}
						}
					]
				}
			}


			## no idea why the fuck this is not working.

			search_response =  cls.gateway.client.search :body => {query: query}, index: index_name, :type => document_type

			puts search_response.to_s
			
			hit = search_response["hits"]["hits"].first

			#hit = cls.gateway.client.get :id => args[:id], :index => Stock.index_name, :type => Stock.document_type
			raise Elasticsearch::Transport::Transport::Error if hit.blank?
			e = cls.new(hit["_source"])
			e.id = hit["_id"]
			puts "args--> #{args}"
			e.attributes.merge!(args)
		rescue Elasticsearch::Transport::Transport::Error
			#puts "rescuing."
			puts "args setting :#{args}"
			e = cls.new(args)
			#puts "args are :#{args}"
			e.set_name_description_link
			puts "---------- came past that ---------------- "
		end
		puts "trigger udpate is--------------: #{e.trigger_update}"
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