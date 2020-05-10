require 'elasticsearch/persistence/model'

class Indicator 

	## we include them as concerns.
	include Elasticsearch::Persistence::Model
	include Concerns::EsBulkIndexConcern
	include Concerns::Stock::IndividualConcern
	include Concerns::Stock::CombinationConcern
	include Concerns::BackgroundJobConcern
	include Concerns::Stock::EntityConcern

	## so that way we can do that also
	## stocks is ok ->
	## but when you show single stock ->
	## the top card is ok
	## below that start the first full search result
	## and then individual search results.
	## with pagination
	## first fix the mobile mess
	## then the continuous looping on stock pages
	## we have the stock top results
	## we have its combinations.
	## so we can have two cards ?
	## improve the top cards
	## and the way the combinations are shown.
	## 


	INDICATORS_JSONFILE = "indicators.json"
	INFORMATION_TYPE_INDICATOR = "indicator"
	MAX_INDICATORS = 1
	INDICATOR_NAMES_AND_ABBREVIATIONS = {
		"stochastic_oscillator_d_indicator" => "SOD Indicator",
		"stochastic_oscillator_k_indicator" => "SOK Indicator",
		"average_directional_movement_indicator" => "ADM Indicator",
		"double_ema_indicator" => "DEMA Indicator",
		"awesome_oscillator_indicator" => "AO Indicator",
		"triple_ema_indicator" => "TEMA Indicator",
		"single_ema_indicator" => "SEMA Indicator",
		"moving_average_convergence_divergence" => "MACD Indicator",
		"acceleration_deceleration_indicator" => "AD Indicator",
		"relative_strength_indicator" => "RSI Indicator",
		"williams_r_indicator" => "WR Indicator",
		"aroon_up" => "Aroon Up Indicator",
		"aroon_down" => "Aroon Down Indicator",
		"cci_indicator" => "CCI Indicator"
	}
	

	def self.update_many
		get_all_indicator_informations.each do |hit|
			indicator = find_or_initialize({id: hit["_id"], trigger_update: true, :class_name => "Indicator"})
			indicator.save
		end
	end


	## burkha chodsa
	def self.get_all
		query = {
			bool: {
				must: {
					term: {
						stock_information_type: "indicator"
					}
				}
			}
		}
		response = Hashie::Mash.new Indicator.gateway.client.search :body => {:size => MAX_INDICATORS, :query => query}, :index => index_name , :type => document_type
		
		puts "Response is:"
		puts response.to_s


		response.hits.hits
	end


	def self.get_all_indicator_informations
		query = {
			bool: {
				must: [
					{
						term: {
							information_type: INFORMATION_TYPE_INDICATOR
						}
					}
				]
			}
		}	
		#puts query.to_s

		response = Hashie::Mash.new Indicator.gateway.client.search :body => {:size => MAX_INDICATORS, :query => query}, :index => "correlations", :type => "result"
		
		response.hits.hits
	end

	##########################################################3
	##
	##
	## METHODS OVERRIDEN FROM ENTITY_CONCERN
	##
	##
	###########################################################
	def update_top_results
		self.stock_top_results = Result.nested_function_score_query(self.stock_name,nil,nil)[0..4].map{|c| Result.build_setup(c) }
		puts "the stock top results are:"
		puts self.stock_top_results.to_s
	end


	def get_information
		query = {
			bool: {
				must: [
					{
						term: {
							information_type: INFORMATION_TYPE_INDICATOR
						}
					},
					{
						term: {
							information_name: self.id.to_s
						}
					}
				]
			}
		}

		#puts query.to_s

		response = Hashie::Mash.new Indicator.gateway.client.search :body => {:size => 1, :query => query}, :index => "correlations", :type => "result"
		
		puts "Response is:"
		puts response.to_s

		info = nil

		if response.hits.hits.size > 0
			info = response.hits.hits.first
		end

		info

	end

	## @params[String] id : the id of the stock
	## @return[Stock] e : either the stock if it exists, otherwise a new instance of an stock, with the provided id. 
	def self.find_or_initialize(args={})
		e = nil
		cls = args.delete(:class_name) || "Indicator"
		cls = cls.constantize
		return cls.new(args) if ((args[:id].blank?))
		begin
			puts index_name
			puts document_type

			query = {
				bool: {
					must: [
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

end