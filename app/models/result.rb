require 'elasticsearch/persistence/model'

class Result
	include Mongoid::Document
	SUBINDICATOR_SUGGESTIONS = ["moving averages cross","pattern","standard deviation","falls","rises","sets a high","sets a low"]
	INDICATOR_SUGGESTIONS = ["Acceleration Decelaration","Awesome Oscillator","Relative Strength","Average Directional Movement","Moving Average Convergence Divergence","Simple Moving Average","Exponential Moving Average","Double Exponential Moving Average","Triple Exponential Moving Average","CCI Indicator","Williams R Indicator","Stochastic Oscillator K Indicator","Stochastic Osciallator D Indicator","Aroon Up","Aroon Down"]
	#generate permutataions, and see what has gone wrong.
	#include Mongoid::Elasticsearch
  	#elasticsearch!
  	SEPARATOR_FOR_TAG_TEXT = "^^"
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

	def self.reload_front_page_trend
		puts "came to reload front page trend."
		$front_page_trend_loaded_at ||= Time.now - 6.hours
		if Time.now.to_i > $front_page_trend_loaded_at.to_i
			puts "current time is greater #{(Time.now.to_i - $front_page_trend_loaded_at.to_i)}"
			if ((Time.now.to_i - $front_page_trend_loaded_at.to_i) > 3600*4)
				puts "setting front page trend."
				$front_page_trend = front_page_trend
				puts "front page trend is;"
				puts $front_page_trend
				$front_page_trend_loaded_at = Time.now
			end
		end
	end
	## maybe i can get just the first 5 or something.
	## so any number of trends.
	## we can store.
	## but it will become an ajax call whichever way you go for it.
	def self.front_page_trend
		gateway.client.get index: "correlations", id: "R-front_page_trend"
	end

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

	def self.new_match_query(query)
		## first basic match.
		## should[1][:nested][:query][:bool][:should]
		## sort out stubbing for close

		puts "RUNNING NEW MATCH QUERY."
		
		query = query.downcase

		## its going to be inner_hits with function score.
		## that includes the entire tag text
		## the scoring will include its profitability.
		## at the level of the inner hit.
		## then we can see what happens.
		## not hard to change.
		## so we don't match on anything much else.
		## add that entire thing to the complex_derivations
		## tag text.

		should = [
			{
				match: {
					"tags.english".to_sym => query
				}
			},
			{
				nested: {
					path: "complex_derivations",
					query: {
						bool: {
							should: [
								{
									match: {
										"complex_derivations.tag_text".to_sym => query
									}
								},
								{
									match: {
										"complex_derivations.industries".to_sym => query
									}
								} 
							]
						}
					},
					inner_hits: {}
				}
			},
			{
				nested: {
		 			path: "complex_derivations",
		 			query: {
		 				bool: {
		 					should: [
														
		 					]
		 				}
		 			},
		 			inner_hits: {}
		 		}
			}
		] 

		query_split = query.split(" ")
		#puts "query split is: #{query_split}"
		base_boost = 100
		query_split.each_with_index {|word,key|
			if (key < (query_split.size - 1)) 
				should << {
					span_near: {
						clauses: [
							{
								span_term: {
					                "tag_text".to_sym => {
					                  value: query_split[key]
					                }
				            	}
				        	},
				        	{
					            span_term: {
					                "tag_text".to_sym => {
					                  value: query_split[key + 1]
					                }
					            }
				        	}
						],
						slop: 10,
						in_order: true,
						boost: 100
					}
				}
				should[2][:nested][:query][:bool][:should] << {
					span_near: {
						clauses: [
							{
								span_term: {
					                "complex_derivations.tag_text".to_sym => {
					                  value: query_split[key]
					                }
				            	}
				        	},
				        	{
					            span_term: {
					                "complex_derivations.tag_text".to_sym => {
					                  value: query_split[key + 1]
					                }
					            }
				        	}
						],
						slop: 10,
						in_order: true,
						boost: 100
					}
				}
				base_boost = base_boost/2
			end
		}

		
		if should[2][:nested][:query][:bool][:should].blank?
			should.pop
		end

		puts "should clauses are:"
		puts JSON.pretty_generate(should)


		body = 
		{
	  		_source: ["tags","preposition","epoch","_id"],
		  	query: {
			  	function_score: {
			  		query: {
			  			bool: {
					      should: should
					    }
			  		},
			  		functions: [
			  			{
			  				## you are only using epoch.
			  				## you are not using the profitability
			  				## so that has to be defined where ?
			  				## in the complex derivation for what ?
			  				## you have to sort by the score of the inner hit.
			  				## also add gauss on the profitablility
			  				## this is going to have to be stored on the complex derivation.
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

		
		search_results = gateway.client.search index: "correlations", body: body

		## as far as industries are concerned
		## i want to know what.
		## buy bmw?
		## buy what?
		## so search inside inner hits.

		search_results = search_results["hits"]["hits"].map{|hit|
			#puts JSON.generate(hit)
			puts JSON.generate(hit["inner_hits"]["complex_derivations"]["hits"]["hits"])
			object_to_use = hit["inner_hits"]["complex_derivations"]["hits"]["hits"][0]

			# if it doesn't contain the time tag_text
			# then we have to get it from the suggest.
			entity_name = nil
			if object_to_use["_source"]["tag_text"].blank?
				entity_name = object_to_use["_source"]["tags"][0]
			else
				entity_names = object_to_use["_source"]["tag_text"].split(SEPARATOR_FOR_TAG_TEXT)[0].split(",")
				selected_names = entity_names.select{|c| query =~ /c/i }
				entity_name = nil

				if selected_names.blank?
					entity_name = entity_names[0]	
				else
					entity_name = selected_names[0]
				end
			end

			input = entity_name + "#" +  object_to_use["_source"]["stats"].join(",") + "," + object_to_use["_source"]["industries"].join(",") + "*#{entity_name.size},0" 

		
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

	def self.must_query_builder(direction)
		if direction.blank?
			{
				terms: {
					"complex_derivations.trend_direction".to_sym => ["rise","fall"]
				}
			}
		else
			{
				term: {
					"complex_derivations.trend_direction".to_sym => direction
				}
			}
		end
	end

	def self.should_query_builder(query_string)
		#puts "query string is :#{query_string}"
		unless $sectors_name_to_counter[query_string].blank?
			#puts "Sectors not blank."
			{
					match_phrase: {
						"complex_derivations.industries".to_sym =>  {
							query: query_string,
							slop: 10
						}
					}
			}
		else
			#puts "sectors blank."
			qs = query_string
			#puts "qs becomes: #{qs}"
			if qs.size == 1
				#puts "Size is 1, qs 0 is #{qs[0]}"
				{
					match_phrase: {
						"complex_derivations.tag_text".to_sym =>  {
							query: qs[0],
							slop: 10
						}
					}
				}
			else
				#puts "size is more than one."
				qs[0..-2].map.each_with_index{|val,key|
					{
						match_phrase: {
							"complex_derivations.tag_text".to_sym =>  {
								query: val + " " + qs[key + 1],
								slop: 10
							}
						}
					}
				}
			end
		end
	end


	def get_positive_indicators
		## sort by p_val, and search for trend_direction "rise"
		## or sort by profitability.
		## or sort by trend_percentage -> just the precentages.
	end

	def get_negative_indicators
		## sort by p_val, and search for trend_direction "fall"
	end

	def self.match_phrase_query_builder(query,direction)
		qs = query.split(" ")
		body = {
			_source: ["tags","preposition","epoch","_id"],
			query: {
				nested: {
					path: "complex_derivations",
					query: {
						function_score: {
							query: {
								bool: {
									should: [
										should_query_builder(qs)
									],
									must: [
										must_query_builder(direction)
									]
								}
							},
							functions: [
								{
									field_value_factor: {
										field: "complex_derivations.profitability",
										modifier: "sqrt"
									}
								}
							],
							boost_mode: "sum"
						}
					},
					inner_hits: {
						size: 1
					},
					score_mode: "max"
				}
			}
		}
	end


	## so if you click see more positive indicators, what is it expected to show ?
	## actually ?
	def self.query_builder(query)

		body = 
		{
	  		_source: ["tags","preposition","epoch","_id"],
		  	query: {
			  	nested: {
			  		path: "complex_derivations",
			  		query: {
			  			function_score: {
			  				query: {
			  					bool: {
			  						should: [
			  							{
				  							span_near: {
												clauses: query.split(" ").map{|word|
													{
														span_term: {
											                "complex_derivations.tag_text".to_sym => {
											                  value: word
											                }
										            	}
										        	}
												},
												slop: 20,
												in_order: true,
												boost: 110
											}
										},
										{
											match: {
												"complex_derivations.tag_text".to_sym => query
											}
										}
			  						]
			  					}
			  				},
			  				functions: [
			  					{
				                    field_value_factor: {
				                      	field: "complex_derivations.profitability"
				                    }
				                }
			  				],
			  				boost_mode: "multiply"
			  			}
			  		},
			  		inner_hits: {}
			  	}
		  	}
		}

	end

	def self.nested_function_score_query(query,direction=nil)

		body = match_phrase_query_builder(query,direction)

		puts JSON.pretty_generate(body)

		search_results = gateway.client.search index: "correlations", body: body

		search_results = search_results["hits"]["hits"].map{|hit|
			#puts JSON.generate(hit)
			
			object_to_use = hit["inner_hits"]["complex_derivations"]["hits"]["hits"][0]

			# if it doesn't contain the time tag_text
			# then we have to get it from the suggest.
			entity_name = nil
			if object_to_use["_source"]["tag_text"].blank?
				entity_name = object_to_use["_source"]["tags"][0]
			else
				entity_names = object_to_use["_source"]["tag_text"].split(SEPARATOR_FOR_TAG_TEXT)[0].split(",")
				selected_names = entity_names.select{|c| query =~ /c/i }
				entity_name = nil

				if selected_names.blank?
					entity_name = entity_names[0]	
				else
					entity_name = selected_names[0]
				end
			end

			## so the stats here is the year wise data.
			## how is it coming currently
			## there are two things.
			## and then the total up and down
			## then $$start
			total_up = 0
			total_down = 0
			object_to_use["_source"]["stats"][0..-7].each_slice(3) do |year_data|
				#puts "year data is:"
				#puts year_data.to_s
				total_up += year_data[1]
				total_down += year_data[2]
			end

			## so there is some issue here.
			## tso problem
			input = entity_name + "#" +  "#{total_up}$$" + object_to_use["_source"]["stats"].join("$") + ",#{total_down}" + ",0,0,0,0,0,0,0,0,0,0,0" + object_to_use["_source"]["industries"].join(",") + "*#{entity_name.size},0" 

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
					],
					## debug here.
					trend_direction: object_to_use["_source"]["trend_direction"],
					nearest_epoch: object_to_use["_source"]["nearest_epoch"],
					epoch_score: object_to_use["_source"]["epoch_score"],
					gd_forward_epoch_score: object_to_use["_source"]["gd_forward_epoch_score"],
					current_datapoint_epoch: object_to_use["_source"]["current_datapoint_epoch"],
					p_val: object_to_use["_source"]["p_val"]
				}
			}

		}

	end

	def self.basic_match_query(query)

		## just search as follows
		## all the terms in the complex derivation tags
		## should each individual word in the complex derivation tags

		## secondly if any of the 


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

			## that query has a ten fold boost.
			## where we match all the words
			## okay i can manage this.		

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

		#puts "query body"
		#puts JSON.pretty_generate(body)

		search_results = gateway.client.search index: "correlations", body: body

		#puts "search results size:"
		#puts search_results["hits"]["hits"].size
		search_results = search_results["hits"]["hits"].map{|hit|
			puts "this is the hit------------->"
			puts JSON.generate(hit)
			## so it depends which hit matched.
			## either tags or industries.
			## both have to be checke.
			#puts "these are the inner hits -------------->"
			#puts hit["inner_hits"]
			#puts "ends------------------------------->"
			object_to_use = nil
			unless hit["inner_hits"]["tags"].blank?
				#puts "using tags."
				object_to_use = hit["inner_hits"]["tags"]
			else
				unless hit["inner_hits"]["industries"].blank?
					object_to_use = hit["inner_hits"]["industries"]
				end
			end
			
				
			matching_tags = object_to_use["hits"]["hits"][0]["_source"]["tags"].select{|c|
				query =~ /c/
			}

			entity_name = nil

			if matching_tags.blank?
				entity_name = object_to_use["hits"]["hits"][0]["_source"]["tags"][0]
			else
				entity_name = matching_tags[0]
			end

			## so upto the seperator.
			## its one of the two.


			input = entity_name + "#" +  object_to_use["hits"]["hits"][0]["_source"]["stats"].join(",") + "," + object_to_use["hits"]["hits"][0]["_source"]["industries"].join(",") + "*#{entity_name.size},0" 

			## could become problematic.

			puts "input becomes --------------------------- >"
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
		puts "input is: #{input}" 
		sectors = []
		parts = input.split("#")
		stats = parts[1].split(",")
		related_queries = []
		## so we have to add these also.
		## later on on the side.
		## so gotta do this here.
		#puts "the input is:"
		#puts input.to_s
		#we need part between # and start
		#puts input.to_s
		stats_and_industries = nil
		offsets = nil
		#puts "the input is:"
		#puts input.to_s
		#so i will add the week total up.
		#as the first two.
		#and transpose the rest to it.
		input.scan(/#(?<stats>[0-9A-Za-z\s,\-\$]+)\*(?<offsets>[0-9,]+)$/) do |jj|
			stats_and_industries = jj[0]
			offsets = jj[1]
		end

=begin
		stats_and_industries.split(",")[12..-1].each do |industry_code|
			unless $sectors[industry_code.to_s].blank?
				industry_name = $sectors[industry_code.to_s].information_name
				related_queries.push($sectors[industry_code.to_s].related_queries)
				sectors.push(industry_name)
			end
		end
=end
		#puts "stats and industries #{stats_and_industries}"
		#puts "offsets:#{offsets}"
		stats = stats_and_industries.split(",")[0]
		
		stats_and_industries.split(",")[12..-1].each do |industry_name|
			#unless $sectors[industry_code.to_s].blank?
				#industry_name = $sectors[industry_code.to_s].information_name
				#set this in the initializer.
				if sector_counter = $sectors_name_to_counter[industry_name]
					related_queries.push($sectors[sector_counter].related_queries)
					sectors.push(industry_name)
				end
			#end
		end
		#puts "the sectors are:"
		#puts sectors.to_s
		#puts "stats are:"
		#puts stats.to_s
		#okay so here we have to manage it.
		input = parts[0] + "#" + stats_and_industries.split(",")[0..11].join(",") + "," + sectors.join(",") + "%" + related_queries.flatten.join(",") + "*" + offsets
		
		input
	end

	def self.directional_query(query,direction)

	end

	def self.debug_suggest_r(args)

		search_results = nested_function_score_query(args[:prefix])

		puts "the search results are;"

		if search_results.blank?
			puts JSON.pretty_generate(search_results)
		else
			puts JSON.pretty_generate(search_results)
		end

		results = {
			#:search_results => search_results,
			:search_results => search_results,
			:query_suggestion_results => [],
			:effective_query => nil
		}

		results

	end

	## default values for prefix and context are provided in the method as '' and [] respectively.
	def self.suggest_r(args)
			
		search_results = []

		unless args[:direction].blank?

			search_results = nested_function_score_query(args[:prefix],args[:direction])

		else
			
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
			                size: 8
			            }
					}
				}
			}

			query_suggestion_results = []

			search_start_time = Time.now.to_i
			search_results = gateway.client.search index: "correlations", body: body
			#puts search_results["suggest"].to_s
			search_end_time = Time.now.to_i
			#puts "elasticsearch query took-----------6+--"
			#puts (search_end_time - search_start_time)

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

				## write what is / explain
				## 
				
			else
				search_results = []
			end

	#			end

			#end

			if search_results.blank?
				puts "search results were blank."
				## now we have a situation where we have to fall back onto the ngram query.
				#new_match_query(args[:prefix])
				search_results = nested_function_score_query(args[:prefix])
			end

		end

		puts "the search results are;"

		if search_results.blank?
			puts JSON.pretty_generate(search_results)
		else
			puts JSON.pretty_generate(search_results)
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