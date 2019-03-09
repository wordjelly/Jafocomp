require 'elasticsearch/persistence/model'

class Result
	include Mongoid::Document
	#include Mongoid::Elasticsearch
  	#elasticsearch!
	include Elasticsearch::Persistence::Model
	field :setup, type: String
	field :setup_exit, type: String
	field :triggered_at, type: Integer
	## should have a field called, action, that is inferred from the user query, like 'buy' or 'sell'
	## 0 -> buy
	## 1 -> sell
	field :trade_action, type: Integer
	field :trade_action_name, type: String
	field :trade_action_end, type: Integer
	field :trade_action_end_name, type: String
	embeds_many :impacts, :class_name => "Impact"

	## @param[Hash] args : expected to have one key called information.
	def self.information(args)

		args ||= {:information => ''}
		args[:information] ||= ''

		body = {
			query: {
				match: {
					information_name: {
						query: args[:information]
					}
				}
			}
		}

		results = gateway.client.search index: "correlations", body: body
		
		#puts JSON.pretty_generate(results)
		if results["hits"]
			results["hits"]["hits"][0]["_source"]
		else
			[]
		end

	end

	def self.simple_match_query(query_text)

		body = {
			_source: ["suggest"], 
			query: {
				nested: {
					path: "complex_derivations",
					query: {
						match: {
							"complex_derivations.impacted_entity_name".to_sym => query_text 
						}
					}
				}
			}
		}

		response = gateway.client.search index: "correlations", body: body

		response

	end

	## this will join the last successfull query, and the top result from the suggested_Query, and perform a basic query, and return teh results.
	def self.compound_query(last_successfull_query,query_suggestion_results,whole_query)

		if query_suggestion_results["suggest"]["correlation_suggestion"][0]["options"].blank?

			puts "auto suggest didnt find anything - so did a match query , with whole query: #{whole_query}"

			simple_match_query(whole_query)

		else

			puts "found some suggestions, so trying to combine last succesffull query."

			top_suggestion = query_suggestion_results["suggest"]["correlation_suggestion"][0]["options"][0]["_source"]["suggest_query_payload"]

			## that part worked, but we need to add the apostrophe for this shit to work properly.
			## so will have to add that apostrophe.
			effective_query = last_successfull_query + " " + top_suggestion

			body = {
					_source: ["suggest"], 
					suggest: {
						correlation_suggestion: {
							text: effective_query,
							completion: {
				                field: "suggest",
				                size: 10
				            }
						}
					}
			}
			puts JSON.pretty_generate(body)

			response = gateway.client.search index: "correlations", body: body

			#puts "response is=-=================>"
			#puts response.to_s

			mash = Hashie::Mash.new response
			if mash.suggest.correlation_suggestion[0].options.empty?
				puts "no results in combined query, so going for match query."
				simple_match_query(whole_query)
			else
				puts "got resutls in combined query."
				response["effective_query"] = effective_query
				response
			end

		end

	end

	## default values for prefix and context are provided in the method as '' and [] respectively.
	def self.suggest_r(args)
		
		puts "came to suggest_r with args"
		puts args.to_s

		args[:prefix] ||= ''
		args[:context] ||= []


		body = {
				_source: ["suggest"], 
				suggest: {
					correlation_suggestion: {
						text: args[:prefix],
						completion: {
			                field: "suggest",
			                size: 10
			            }
					}
				}
		}

			
		unless args[:context].blank?

			puts "tried auto suggest--->"

			body = {
				_source: ["suggest_query_payload"], 
				suggest: {
					correlation_suggestion: {
						text: args[:prefix],
						completion: {
							contexts: {
								"component_type" => args[:context]
							},
			                field: "suggest_query",
			                size: 10
			            }
					}
				}
			}


			query_suggestion_results = gateway.client.search index: "correlations", body: body

			## we want the prefix also.
			search_results = compound_query(args[:last_successfull_query],query_suggestion_results,args[:whole_query]) 
			

			if query_suggestion_results["suggest"]
				query_suggestion_results = query_suggestion_results["suggest"]["correlation_suggestion"][0]["options"]
			else
				query_suggestion_results = []
			end

			


			if search_results["suggest"]
				effective_query = search_results["effective_query"]
				search_results = search_results["suggest"]["correlation_suggestion"][0]["options"]
				#puts "search results becomes:"
				#puts search_results.to_s
			elsif search_results["hits"]["hits"]
				search_results = search_results["hits"]["hits"]
			end

		
		else

			query_suggestion_results = []

			search_results = gateway.client.search index: "correlations", body: body

			if search_results["suggest"]
				search_results = search_results["suggest"]["correlation_suggestion"][0]["options"]
				#puts "search results becomes:"
				#puts search_results.to_s
			else
				search_results = []
			end

		end

		
		

		results = {
			:search_results => search_results,
			:query_suggestion_results => query_suggestion_results,
			:effective_query => effective_query
		}
			
		#puts "results -----------------> "
		#puts JSON.pretty_generate(results)

		results

	end

end