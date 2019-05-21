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

		body = 
		{
			_source: ["information_name","information_description","information_link"], 
			query: {
				bool: {
					should: [
						{
							match: {
								information_name: args[:information].strip
							}
						},
						{
							prefix: {
								"information_name.raw".to_sym => args[:information].strip[0..20]
							}
						}
					]
				}
			},
			size: 1
		}


		results = gateway.client.search index: "correlations", body: body
		
		puts JSON.pretty_generate(results["hits"]["hits"])
		if results["hits"]
			results["hits"]["hits"]
		else
			[]
		end

	end

	def self.simple_match_query(query_text)

		match_query_clauses = query_text.split(" ").map{|c|
			c = {
				constant_score: {
	                filter: {
		                term: {
		                    "complex_derivations.impacted_entity_name".to_sym => c
		                }
	                }
	            }  
			}
		}

		body = {
			_source: false, 
			query: {
				nested: {
					path: "complex_derivations",
					query: {
						bool: {
							disable_coord: true,
							should: match_query_clauses
						}
					},
					inner_hits: {}
				}
			}
		}

		puts JSON.pretty_generate(body)

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

	def self.basic_match_query(query)
		query_split_on_space = query.split(" ")
		
		should_query_clauses = []
	 	nested_query_clauses = []
	 	## this should be possible, but what about the speed of this query
	 	## that is the big problem.
	 	total_terms = query_split_on_space.size
		query_split_on_space.each_with_index.map{|c,i|
			should_query_clauses << {
				prefix: {
					tags: {
						value: c.gsub(/\'s$/,'')[0..9],
						boost: i*10
					}
				}
			}
			nested_query_clauses << {
				prefix: 
					{
			            "complex_derivations.tags".to_sym => {
			                  value: c.gsub(/\'s$/,'')[0..9],
			                  boost: (total_terms - i)*10
			                }
		            }
			}
		}

		body = {
		  _source: ["tags","preposition","epoch","_id"],
		  query: {
		    bool: {
		      must: [
		        {
		          bool: {
		            should: should_query_clauses
		          }
		        }
		      ],
		      should: [
		        {
		          nested: {
		            path: "complex_derivations",
		            query: {
                        bool: {
                        	should: nested_query_clauses
                        } 
		            },
		            inner_hits: {}
		          } 
		        }
		      ]
		    }
		  }
		}

		puts "query body"
		puts JSON.pretty_generate(body)

		search_results = gateway.client.search index: "correlations", body: body

		puts "search results size:"
		puts search_results["hits"]["hits"].size
		search_results = search_results["hits"]["hits"].map{|hit|
				
			puts hit.to_s

			input = hit["inner_hits"]["complex_derivations"]["hits"]["hits"][0]["_source"]["tags"].join(" ") + "#" +  hit["inner_hits"]["complex_derivations"]["hits"]["hits"][0]["_source"]["stats"].join(",")

			hit = {
				_id: hit["_id"],
				_source: {
					preposition: hit["_source"]["preposition"],
					epoch: hit["_source"]["epoch"],
					tags: hit["_source"]["tags"],
					suggest: [
						{
							input: input
						}
					]
				}
			}
		}

	end

	## default values for prefix and context are provided in the method as '' and [] respectively.
	def self.suggest_r(args)
		
		search_results = []
		
		puts "came to suggest_r with args"
		puts args.to_s

		args[:prefix] ||= ''
		args[:context] ||= []

		body = {
			_source: ["suggest","tags","preposition","epoch","_id"], 
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

			query_suggestion_results = []

			search_start_time = Time.now.to_i
			search_results = gateway.client.search index: "correlations", body: body
			#puts search_results["suggest"].to_s
			search_end_time = Time.now.to_i
			puts "elasticsearch query took-------------"
			puts (search_end_time - search_start_time)

			if search_results["suggest"]
				search_results = search_results["suggest"]["correlation_suggestion"][0]["options"]
				
				search_results.map!{|c|
					txt = c["text"]
					txt = txt.split("#")[0].split(" ")
					puts "the text parts are:"
					puts txt.to_s
					c["_source"]["suggest"] = c["_source"]["suggest"].select{|d|
						results = txt.map{|k|
							d["input"] =~ /#{k}/
						}.compact
						results.size == txt.size
					}[0..0]
					c
				}
				puts "the search results become:"
				puts JSON.pretty_generate(search_results)
				## so each of the search-results
				## we want only one suggestion.
				#puts JSON.pretty_generate(search_results)
			else
				search_results = []
			end

#			end

		#end

		if search_results.blank?
			puts "search results were blank."
			## now we have a situation where we have to fall back onto the ngram query.
			search_results = basic_match_query(args[:prefix])
		end

		results = {
			#:search_results => search_results,
			:search_results => search_results,
			:query_suggestion_results => query_suggestion_results,
			:effective_query => nil
		}

		results

	end

end