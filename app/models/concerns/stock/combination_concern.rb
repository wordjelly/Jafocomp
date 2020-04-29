module Concerns::Stock::CombinationConcern
	
	extend ActiveSupport::Concern

	included do 

		## @param[Hash] args
		## :stock_impacted[OPTIONAL] : the name of the stock
		## :stock_primary[OPTIONAL] : the name of the stock.
		## @return[Array[Stock]] : array of stock objects (combination stock objects.)
		def self.get_all_combination_entities(args={})
			query = {
				bool: {
					must: [
						{
							term: {
								stock_result_type: Stock::COMBINATION
							}
						}
					]
				}
			}

			query[:bool][:must] << {
				term: {
					stock_primary: args[:stock_primary]
				}
			} unless args[:stock_primary].blank?

			query[:bool][:must] << {
				term: {
					stock_impacted: args[:stock_impacted]
				}
			} unless args[:stock_impacted].blank?
			
			search_request = Stock.search({
				query: query,
				size: 180
			})

			search_request.response.hits.hits.map{|c|

				e = Stock.new(c["_source"])
				e.id = c["_id"]
			}

		end

		def update_combinations
			names_by_index = get_all_other_stocks
			# now a bulk search query ?
			names_by_index.keys.each do |index|
				names = names_by_index[index]
				names.each_slice(50) do |slice|
					## each search_request should have an index and a body.
					search_requests = slice.map{|c|
						
						q = Result.match_phrase_query_builder(c.stock_name,nil,self.id.to_s)

						q.deep_symbolize_keys!
						{
							index: "correlations",
							type: "result",
							_source: q[:_source],
							search: {
								query: q[:query]
							}
						}
					}

					puts JSON.pretty_generate(search_requests)

					multi_response = Stock.gateway.client.msearch body: search_requests

					multi_response["responses"].each_with_index {|search_results,key|

						primary_stock = slice[key]
						hits = Result.parse_nested_search_results(search_results,primary_stock.stock_name)
						s = Stock.new

						s.stock_top_results = hits
						s.stock_impacted_id = self.id.to_s
						s.stock_impacted = self.stock_name
						s.stock_impacted_description = self.stock_description
						s.stock_impacted_link = self.stock_link
						s.stock_impacted_exchange = self.stock_exchange

						s.stock_primary = primary_stock.stock_name
						s.stock_primary_id = primary_stock.id.to_s
						s.stock_primary_description = primary_stock.stock_description
						s.stock_primary_link = primary_stock.stock_link
						s.stock_primary_exchange = primary_stock.stock_exchange
						s.generate_combination_name
						s.generate_combination_description
						s.stock_result_type = Stock::COMBINATION
						#puts "adding bulk item"
						#puts s.attributes.to_s
						#exit(1)
						Stock.add_bulk_item(s)
					}

				end 
				Stock.flush_bulk
			end
		end

		def update_combination_top_hits
			
		end

		
		def generate_combination_description
			"Interactions between #{self.stock_primary} and #{self.stock_impacted}"
		end

		def generate_combination_name
			"How Does #{self.stock_primary} affect #{self.stock_impacted} ?"
		end
		
		def get_all_other_stocks
			
			other_stocks_by_index = {}

			query = {
				bool: {
					must: [
						{
							term: {
								information_type: "entity"
							}
						}
					]
				}
			}

			response = Hashie::Mash.new Stock.gateway.client.search :body => {:size => 200, :query => query}, :index => "correlations", :type => "result"
			

			response.hits.hits.each do |hit|
				index_name = hit._source.information_exchange_name
				other_stocks_by_index[index_name] ||= []
				s = Stock.new
				s.stock_name = hit._source.information_name
				s.stock_description = hit._source.information_description
				s.stock_link = hit._source.information_link
				s.id = hit._source.information_id
				other_stocks_by_index[index_name] << s
			end

			#puts JSON.pretty_generate(other_stocks_by_index)
			#exit(1)
			other_stocks_by_index

		end

		def get_all_indicator_names

		end

	end
end