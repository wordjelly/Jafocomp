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

=begin
	## we make all the entity permutations, before hand.
	## and then we simply increment one if it is found.
	## how to make the permutations ?ds
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
=end
	def self.basic_match_query(query)
		query_split_on_space = query.split(" ")


		should_query_clauses = []
	 	nested_query_clauses = []
	 	## this should be possible, but what about the speed of this query
	 	## that is the big problem.
	 	total_terms = query_split_on_space.size

	 	## so if we get a match.
	 	## we don't need to split the tags ?
	 	## indian it stocks.
	 	## 
	 	## what to test ?
	 	## it is generating the report
	 	## now for the report options.
	 	tags_nested_query = {
	 		nested: {
	 			path: "complex_derivations",
	 			query: {
	 				bool: {
	 					should: [
	 						
	 					]
	 				}
	 			},
	 			inner_hits: {
	 				name: "tags",
	 				size: 3
	 			}
	 		}
	 	}

	 	industries_nested_query = {
	 		nested: {
	 			path: "complex_derivations",
	 			query: {
	 				bool: {
	 					should: [
	 						
	 					]
	 				}
	 			},
	 			inner_hits: {
	 				name: "industries",
	 				size: 3
	 			}
	 		}	
	 	}

	 	unless $sectors_name_to_counter[query].blank?

		 	should_query_clauses << {
		 		term: {
		 			industries: $sectors_name_to_counter[query]
		 		}
		 	}

		 	industries_nested_query[:nested][:query][:bool][:should] << 
		 	{
		 		term: 
		 		{
				 	"complex_derivations.industries".to_sym => $sectors_name_to_counter[query]
				}
		 	}

=begin
		 	nested_query_clauses << {
		 		nested: {
		 			path: "complex_derivations",
		 			query: {
		 				term: {
				 			"complex_derivations.industries".to_sym => $sectors_name_to_counter[query]
				 		}
		 			},
		 			inner_hits: {
		 				name: "industries",
		 				size: 2
		 			}
		 		}
		 	}
=end
	 	end

	 	
	 	## THESE ARE THE MATCH QUERIES.
	 	## SENDS THE QUERY EN BLOC.
	 	should_query_clauses << {
			match: {
				"tags.english".to_sym => query
			}
		}

		tags_nested_query[:nested][:query][:bool][:should] << 
			{
				match: 
				{
		            "complex_derivations.tags.english".to_sym => query
	            }
			}

		query_split_on_space.each_with_index.map{|c,i|
			should_query_clauses << {
				prefix: {
					tags: {
						value: c.gsub(/\'s$/,'')[0..9].downcase
					}
				}
			}
			should_query_clauses << {
				prefix: {
					industries: {
						value: c.gsub(/\'s$/,'')[0..9].downcase
					}
				}
			}


			tags_nested_query[:nested][:query][:bool][:should] << 
			{
				prefix: 
				{
		            "complex_derivations.tags".to_sym => {
		                  value: c.gsub(/\'s$/,'')[0..9].downcase
		                }
	            }
			}

			

			industries_nested_query[:nested][:query][:bool][:should] << 
			{
				prefix: 
				{
		            "complex_derivations.industries".to_sym => {
		                  value: c.gsub(/\'s$/,'')[0..9].downcase
		                }
	            }
			}

		}

		should = (should_query_clauses).flatten
		should << tags_nested_query
		should << industries_nested_query

		## why the scores for this are not working.

		body = {
		  _source: ["tags","preposition","epoch","_id"],
		  query: {
		  	function_score: {
		  		query: {
		  			bool: {
				      should: should,
				      minimum_should_match: 1
				    }
		  		},
		  		functions: [
		  			{
		  				gauss: {
				            epoch: {
				              origin: Time.now.to_i.to_s,
				              scale: "1h"
				            }
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
				
			## so it depends which hit matched.
			## either tags or industries.
			## both have to be checke.
			puts "these are the inner hits -------------->"
			puts hit["inner_hits"]
			puts "ends------------------------------->"
			object_to_use = nil
			unless hit["inner_hits"]["tags"].blank?
				puts "using tags."
				object_to_use = hit["inner_hits"]["tags"]
			else
				unless hit["inner_hits"]["industries"].blank?
					object_to_use = hit["inner_hits"]["industries"]
				end
			end
			puts "object to use is:"
			puts object_to_use.to_s
			input = object_to_use["hits"]["hits"][0]["_source"]["tags"].join(" ") + "#" +  object_to_use["hits"]["hits"][0]["_source"]["stats"].join(",") + "," + object_to_use["hits"]["hits"][0]["_source"]["industries"].join(",") + ","

			puts "input becomes:"
			puts input.to_s
			## here add the industries.
			## and we are in business
			## and then add the chips to the top of the page.
			## or intermittently.

			hit = {
				_id: hit["_id"],
				_source: {
					preposition: hit["_source"]["preposition"],
					epoch: hit["_source"]["epoch"],
					tags: hit["_source"]["tags"],
					suggest: [
						{
							input: plug_industries(input)
						}
					]
				}
			}
		}

	end

	def self.plug_industries(input)
		sectors = []
		parts = input.split("#")
		stats = parts[1].split(",")
		related_queries = []
		## so we have to add these also.
		## later on on the side.
		## so gotta do this here.
		puts "the input is:"
		puts input.to_s
		input.split("#")[1].split(",")[12..-1].each do |industry_code|
			unless $sectors[industry_code.to_s].blank?
				industry_name = $sectors[industry_code.to_s].information_name
				related_queries.push($sectors[industry_code.to_s].related_queries)
				sectors.push(industry_name)
			end
		end
		#puts "the sectors are:"
		#puts sectors.to_s
		#puts "stats are:"
		input = parts[0] + "#" + stats[0..11].join(",") + "," + sectors.join(",") + "%" + related_queries.flatten.join(",")
		#puts "the input becomes:"
		#puts input
		input
	end

	## default values for prefix and context are provided in the method as '' and [] respectively.
	def self.suggest_r(args)
		
		search_results = []
		
		#puts "came to suggest_r with args"
		#puts args.to_s

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
				#puts "the text parts are:"
				#puts txt.to_s
				c["_source"]["suggest"] = c["_source"]["suggest"].select{|d|
					results = txt.map{|k|
						d["input"] =~ /#{k}/
					}.compact
					results.size == txt.size
				}[0..0]
				c["_source"]["suggest"][0]["input"] = plug_industries(c["_source"]["suggest"][0]["input"])
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