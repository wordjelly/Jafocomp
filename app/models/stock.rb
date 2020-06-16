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

	INFORMATION_TYPE = "entity"

	

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
		#puts "Came to find or initialize with args: #{args}"
		e = nil
		cls = args.delete(:class_name) || "Stock"
		cls = cls.constantize
		return cls.new(args) if ((args[:id].blank?))
		begin
			#puts index_name
			#puts document_type

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

			#puts "query is:"
			#puts query.to_s
			## no idea why the fuck this is not working.

			search_response =  cls.gateway.client.search :body => {query: query}, index: index_name, :type => document_type

			#puts search_response.to_s
			
			hit = search_response["hits"]["hits"].first

			#puts "hit is:"
			#puts hit.to_s

			#hit = cls.gateway.client.get :id => args[:id], :index => Stock.index_name, :type => Stock.document_type
			raise Elasticsearch::Transport::Transport::Error if hit.blank?

			e = cls.new(hit["_source"])
			
			
			args.keys.each do |k|
				
				e.send("#{k}=",args[k])
				
			end
			e.id = hit["_id"]
			e.run_callbacks(:find)
			#puts "e div id before: #{e.div_id}"
			#puts "args--> #{args}"
			#ds = args.deep_symbolize_keys
			#puts "ds is #{ds}"
			#e.attributes.merge!(ds)
			#puts "attributes div id after merging:"
			#puts e.div_id
		rescue Elasticsearch::Transport::Transport::Error
			##puts "rescuing."
			#puts "args setting :#{args}"
			e = cls.new(args)
			##puts "args are :#{args}"
			e.set_name_description_link
			#puts "---------- came past that ---------------- "
		end
		#puts "trigger udpate is--------------: #{e.trigger_update}"
		#puts e.trigger_update.to_s
 		e
	end

	## so only show exchanges?
	


end