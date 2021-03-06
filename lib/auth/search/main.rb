require 'mongoid-elasticsearch'
module Auth
	module Search
		module Main
			## this def, returns a hash with the structure for the basic ngram query.
			## the query_string is left blank, and you should merge this in through any def that wants to perform an ngram query.
			## param[Symbol] search_on_field : the field on which we are going to do the n_Gram query. Most of the times this should default to _all_fields
			## @return[Hash]
			def self.es_six_base_ngram_query(search_on_field,highlight_fields=nil)
				qc = {
					body: {
						query: {
							bool: {
								must: [
									bool: {
										should: [
											{
												match: {
													"setup".to_sym => {
														query: "",
														operator: "or",
														boost: 2
													}
												}
											},
											{
												match: {
													"trade_action_name".to_sym => {
														query: "",
														operator: "or",
														boost: 3
													}
												}
											},
											{
												nested: {
													path: "impacts",
													query: {
														bool: {
															must: [
																{
																	match: 
																	{
																		"impacts.entity_name" => {
																				query: "",
																				operator: "or",
																				boost: 4
																		}
																	}
																}
															]
														}
													}
												}
											}
											
										]
									}	
								]
							}
						}
					}
				}

				qc

			end


			## searches all indices, for the search string.
			## @param[Hash] : This is expected to contain the following:
			## @query_string : the query supplied by the user
			## @resource_id : a resource_id with which to filter search results, if its not provided, no filter is used on the search results
			## @size : if not provided a default size of 20 is used
			## this def will use the #base_ngram_query hash and merge in a filter for the resource_id.
			## 'Public' Resources
			##  if the public field is present, don't add any resource_id filter.
			##  if the public field is not present, then add the resource_id filter if the resource_id is provided.
			## @return[Hash] : returns a query clause(hash) 
			def self.es_six_finalize_search_query_clause(args)

				search_on_field = args[:search_field] || :tags
				
				args = args.deep_symbolize_keys
				
				return [] unless args[:query_string]
				
				query = es_six_base_ngram_query(search_on_field)
				
				query[:index] = "correlations"

				query[:size] = args[:size] || 10
					
				query[:body][:query][:bool][:must][0][:bool][:should][0][:match][:setup][:query] = args[:query_string]

				query[:body][:query][:bool][:must][0][:bool][:should][1][:match][:trade_action_name][:query] = args[:query_string]

				query[:body][:query][:bool][:must][0][:bool][:should][2][:nested][:query][:bool][:must][0][:match]["impacts.entity_name"][:query] = args[:query_string]

				query

			end


			## delegates the building of the query to finalize_search_query_clause.
			## @args[Hash] : must have a field called query_string
			## @return[Array] response: an array of mongoid search result objects. 
			def self.search(args)	
				puts "args are:"
				puts args.to_s
				query = es_six_finalize_search_query_clause(args)
				puts "query is:"
				puts JSON.pretty_generate(query)
				res = Mongoid::Elasticsearch.search(query,{:wrapper => :other}).results
				puts "----------------- OUTPUTTING RESULTS ---------------"
				res.each do |res|
					puts res.to_s
				end
				res
			end

			## @param[Hash] args : should contain two keys
			## 1. prefix : string, to search for, defaults to '' 
			## 2. context : the contexts as an array of strings, defaults to an empty array 
			def self.completion_suggester_search(args)

				args[:prefix] ||= ""

				args[:context] ||= []

				query = {	
					suggest: {
						correlation_suggestion: {
							prefix: args[:prefix],
							completion: {
				                field: "suggest",
				                size: 10,
				                contexts: {
				                    "chain": args[:context]
				                }
				            }
						}
					}
				}

				puts JSON.pretty_generate(query)

=begin
#     client.suggest index: 'myindex',
#                    body: { my_suggest: { text: 'tset', term: { field: 'title' } } }
=end
				
				res = Mongoid::Elasticsearch.search(query,{:wrapper => :other}).results

				res.each do |result|
					puts result.to_s
				end

				res

			end

		end
	end
end