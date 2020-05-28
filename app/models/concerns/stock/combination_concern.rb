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
		## @return[Array[self.class]] : array of stock objects (combination stock objects.)
		def self.get_all_combination_entities(args={})
			query = {
				bool: {
					must: [
						{
							term: {
								stock_result_type: 1
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
			
			search_request = search({
				query: query,
				size: 180
			})

			search_request.response.hits.hits.map{|c|

				e = new(c["_source"])
				e.id = c["_id"]
			}

		end
		
		def add_combination_to_self(combination)
			
			script = {
				:lang => "painless",
				:params => {
					exchange: combination.stock_primary_exchange,
					entity_id: combination.stock_primary_id,
					entity_name: combination.stock_primary,
					top_hits: combination.stock_top_results.map{|c| c[:_id].to_s },
					combination_id: combination.id.to_s,
					impacted_entity_id: combination.stock_impacted_id
				},
				:source => '''
					if(ctx._source.combinations.length == 0){
						
						Map entity = new HashMap();
						entity.put("primary_entity_name",params.entity_name);
						entity.put("primary_entity_id",params.entity_id);
						entity.put("primary_entity_exchange",params.exchange);
						entity.put("top_n_hit_ids",params.top_hits);
						entity.put("impacted_entity_id",params.impacted_entity_id);
						entity.put("combination_id",params.combination_id);
							

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
							entity.put("impacted_entity_id",params.impacted_entity_id);
							entity.put("combination_id",params.combination_id);
								

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
					_index: self.class.index_name, _type: self.class.document_type, _id: combination.stock_impacted_id, data: {
							script: script,
							upsert: {},
							scripted_upsert: true
						}
				}
			}


			self.class.add_bulk_item(update_request)
		end


		def combination_from_hits(args)
			primary_stock = args[:primary_stock]
			search_results = args[:search_results]
			impacted_stock = args[:impacted_stock]
			hits = Result.parse_nested_search_results(search_results,primary_stock.stock_name)
			s = self.class.new
			s.stock_top_results = hits
			s.stock_impacted_id = impacted_stock.id.to_s
			s.stock_impacted = impacted_stock.stock_name
			s.stock_impacted_description = impacted_stock.stock_description
			s.stock_impacted_link = impacted_stock.stock_link
			s.stock_impacted_exchange = impacted_stock.stock_exchange
			s.stock_primary = primary_stock.stock_name
			s.stock_primary_id = primary_stock.id.to_s
			s.stock_primary_description = primary_stock.stock_description
			s.stock_primary_link = primary_stock.stock_link
			s.stock_primary_exchange = primary_stock.stock_exchange
			s.stock_information_type = primary_stock.stock_information_type
			s.generate_combination_name
			s.generate_combination_description
			s.stock_result_type = self.class::COMBINATION
			s.id = impacted_stock.id.to_s + "_" + primary_stock.id.to_s			
			s
		end

		def update_combinations
			stocks_by_index = get_all_other_stocks
			
			index_results_for_log = {}

			stocks_by_index.keys.each do |index|
				
				index_results_for_log[index] ||= {}

				stocks = stocks_by_index[index]
				
				stocks.each_slice(50) do |slice|
					
					search_requests = slice.map{|c|
									
						q = Result.match_phrase_query_builder({
							:query => self.stock_name,
							:direction => nil,
							:impacted_entity_id => c.id.to_s
						})

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

					multi_response = self.class.gateway.client.msearch body: search_requests


					multi_response["responses"].each_with_index {|search_results,key|

						s = combination_from_hits({
							primary_stock: self,
							impacted_stock: slice[key],
							search_results: search_results
						})

						index_results_for_log[index][slice[key].stock_name] = search_results.size.to_s

						self.add_combination_to_self(s)

						self.class.add_bulk_item(s)

					}

				end 
				
				self.class.flush_bulk

			end

			Rails.logger.debug("updated combinations for #{self.stock_name} as follows:")
			Rails.logger.debug(JSON.pretty_generate(index_results_for_log))

		end

		def generate_combination_description
			"Interactions between #{self.stock_primary} and #{self.stock_impacted}"
		end

		def generate_combination_name
			"How Does #{self.stock_primary} affect #{self.stock_impacted} ?"
		end
		
		def get_all_other_stocks
			
			#Rails.logger.debug ("getting all other stocks.")
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

			response = Hashie::Mash.new self.class.gateway.client.search :body => {:size => 200, :query => query}, :index => "correlations", :type => "result"
			

			response.hits.hits.each do |hit|
				index_name = hit._source.information_exchange_name
				#index_name = "Test"
				other_stocks_by_index[index_name] ||= []
				s = self.class.new
				s.stock_name = hit._source.information_name
				s.stock_description = hit._source.information_description
				s.stock_link = hit._source.information_link
				s.id = hit._source.information_id
				other_stocks_by_index[index_name] << s
			end

			#mobile ui, is important.
			##puts JSON.pretty_generate(other_stocks_by_index)
			#exit(1)
			other_stocks_by_index

		end

	end
end