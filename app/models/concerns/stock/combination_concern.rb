module Concerns::Stock::CombinationConcern
	
	extend ActiveSupport::Concern

	included do 

		## this hash is built to make it simpler to update the top 5 results in the stock when the combination results are being updated
		## when an entity is updated, we have to update what happens to others due to it.
		## not the other way around.
		## where it is impacted
		## and hence it is a cross update.
		attr_accessor :combination_entity_to_index_hash

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
		
		def update_through_combination(combination)
			
			Rails.logger.debug "came to update through combinations."
			Rails.logger.debug combination.stock_top_results

			script = {
				:lang => "painless",
				:params => {
					exchange: combination.stock_primary_exchange,
					entity_id: combination.stock_primary_id,
					entity_name: combination.stock_primary,
					top_hits: combination.stock_top_results.map{|c| c[:_id].to_s },
					combination_id: combination.id.to_s
				},
				:source => '''
					if(ctx._source.combinations.length == 0){
						
						Map entity = new HashMap();
						entity.put("primary_entity_name",params.entity_name);
						entity.put("primary_entity_id",params.entity_id);
						entity.put("primary_entity_exchange",params.exchange);
						entity.put("top_n_hit_ids",params.top_hits);
							

						ArrayList entities = new ArrayList();
						entities.add(entity);

						Map m = new HashMap();
						m.put("exchange_name",params.exchange);
						m.put("entities",entities);

						ctx._source.combinations.add(m);
					}
					else{
						def has_exchange = 0;
						for(combination in ctx._source.combinations){
							if(combination.exchange_name == params.exchange){
								//for(entity in combination.entities){

								//}
								has_exchange = 1;
							}
						}
						if(has_exchange == 0){
							Map entity = new HashMap();
							entity.put("primary_entity_name",params.entity_name);
							entity.put("primary_entity_id",params.entity_id);
							entity.put("primary_entity_exchange",params.exchange);
							entity.put("top_n_hit_ids",params.top_hits);
								

							ArrayList entities = new ArrayList();
							entities.add(entity);

							Map m = new HashMap();
							m.put("exchange_name",params.exchange);
							m.put("entities",entities);

							ctx._source.combinations.add(m);
						}
					}
				'''
			}

			update_request = {
				update: {
					_index: Stock.index_name, _type: Stock.document_type, _id: combination.stock_impacted_id, data: {
							script: script,
							upsert: {},
							scripted_upsert: true
						}
				}
			}

			Rails.logger.debug "update request for combination update becomes:"
			Rails.logger.debug JSON.pretty_generate(update_request)

			Stock.add_bulk_item(update_request)
		end

		def update_combinations
			Rails.logger.debug("updating combinations.")

			names_by_index = get_all_other_stocks
			# now a bulk search query ?
			Rails.logger.debug "names by index"
			#Rails.logger.debug (JSON.pretty_generate(names_by_index))
			Rails.logger.debug JSON.pretty_generate(names_by_index)
			#exit(1)
			names_by_index.keys.each do |index|
				names = names_by_index[index]
				names.each_slice(50) do |slice|
					## each search_request should have an index and a body.
					search_requests = slice.map{|c|
						
						## so what happens to me, 
						## so we need that id.
						## this goes the other way around.
						## we land up 
						q = Result.match_phrase_query_builder(self.stock_name,nil,c.id.to_s)

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

					#like what happens to nasdaq when 
					#x indicator falls.
					#puts JSON.pretty_generate(search_requests)

					multi_response = Stock.gateway.client.msearch body: search_requests

					multi_response["responses"].each_with_index {|search_results,key|

						primary_stock = self
						hits = Result.parse_nested_search_results(search_results,primary_stock.stock_name)
						s = Stock.new

						s.stock_top_results = hits
						## these have to be updated to self.

						s.stock_impacted_id = slice[key].id.to_s
						s.stock_impacted = slice[key].stock_name
						s.stock_impacted_description = slice[key].stock_description
						s.stock_impacted_link = slice[key].stock_link
						s.stock_impacted_exchange = slice[key].stock_exchange

						s.stock_primary = primary_stock.stock_name
						s.stock_primary_id = primary_stock.id.to_s
						s.stock_primary_description = primary_stock.stock_description
						s.stock_primary_link = primary_stock.stock_link
						s.stock_primary_exchange = primary_stock.stock_exchange
						s.generate_combination_name
						s.generate_combination_description
						s.stock_result_type = Stock::COMBINATION
						
						s.id = slice[key].id.to_s + "_" + primary_stock.id.to_s
						self.update_through_combination(s)

						Stock.add_bulk_item(s)
					}

				end 
				Stock.flush_bulk
			end
		end

		def generate_combination_description
			"Interactions between #{self.stock_primary} and #{self.stock_impacted}"
		end

		def generate_combination_name
			"How Does #{self.stock_primary} affect #{self.stock_impacted} ?"
		end
		
		def get_all_other_stocks
			
			Rails.logger.debug ("getting all other stocks.")
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
				index_name = "Test"
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