require 'elasticsearch/persistence/model'

class Indicator < Stock

	INDICATORS_JSONFILE = "indicators.json"
	INFORMATION_TYPE_INDICATOR = "indicator"
	MAX_INDICATORS = 1

	def schedule_background_update
		puts "------------------------- inside indicator -------- "
		ScheduleJob.perform_later([self.id.to_s,"Indicator","update_it"]) unless self.trigger_update.blank?
		#exit(1)
	end

	def self.update_many
		get_all_indicator_informations.each do |hit|
			indicator = find_or_initialize({id: hit["_id"], trigger_update: true, :class_name => "Indicator"})
			indicator.save
		end
	end



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
		response = Hashie::Mash.new Indicator.gateway.client.search :body => {:size => MAX_INDICATORS, :query => query}, :index => "correlations", :type => "result"
		
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
		
		#puts "Response is:"
		#puts response.to_s


		response.hits.hits
	end

	## now stock_name.
	## should i change the name, the whole thing will go for a six.
	## so we want to see what happens.
	def update_top_results
		puts "---------------- came to update top results."
		puts self.attributes.to_s
		self.stock_top_results = Result.nested_function_score_query(self.stock_name,nil,nil)[0..4].map{|c| Result.build_setup(c) }
		puts "the stock top results are:"
		puts self.stock_top_results.to_s
		exit(1)
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

		response = Hashie::Mash.new Stock.gateway.client.search :body => {:size => 1, :query => query}, :index => "correlations", :type => "result"
		
		puts "Response is:"
		puts response.to_s

		info = nil

		if response.hits.hits.size > 0
			info = response.hits.hits.first
		end

		info

	end

	def update_combinations
		Rails.logger.debug("updating combinations.")

		## so here we want what exactly ?
		## okay this is correct.
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

end