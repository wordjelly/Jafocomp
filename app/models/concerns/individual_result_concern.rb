module Concerns::IndividualResultConcern

	extend ActiveSupport::Concern

  	included do

  	end

  	module ClassMethods

  		SEPARATOR_FOR_TAG_TEXT = "^^"

  		def get_image_url(hit)
  			#####puts "incoming hit in image url"
  			#####puts hit.to_s
  			ratios = [0,20,35,50,65,80,95];
			min_diff = nil;
			min_diff_ratio = nil;
			if (hit["_source"]["rises_or_falls"] =~ /falls/)
				ratios.map!{|c|
					100 - c
				}
			end
			ratios.each_with_index{|el,key|

				diff = (el - hit["_source"]["percentage"]).abs
				if(min_diff.blank?)
					min_diff = diff
					min_diff_ratio = el
				else
					if diff < min_diff
						min_diff = diff
						min_diff_ratio = el
					end
				end
			}
			
			image_url = "up_" + min_diff_ratio.to_s + ".png";
  			facebook_image_url = "up_" + min_diff_ratio.to_s + "_200_200.png"
  			{
  				:social_image_url => image_url,
  				:facebook_image_url => facebook_image_url
   			}
   			
  		end


  		def set_social_parameters(hit)
  			## social_image_url
  			image_urls = get_image_url(hit)

  			hit["_source"]["social_image_url"] = image_urls[:social_image_url]

  			hit["_source"]["facebook_image_url"] = image_urls[:facebook_image_url]

  			## social_description
  			hit["_source"]["social_description"] = hit["_source"]["setup"]
  			#we need start year to end year'
  			#Asian Paints tends to rise 65% 
  			## social_title
  			## Asian Paints tends to rise 100% of the time on Monday
  			## Asian Paints tends to rise 56% of the times when Nifty's RSI Indicator falls.
  			hit["_source"]["social_title"] = hit["_source"]["target"] + ":10 Yr Trends"

  			## social_url
  			hit["_source"]["social_url"] = "https://www.algorini.com/results/" + hit["_id"] + "?entity_id=" + hit["_source"]["impacted_entity_id"];
  		end

		def complex_derivation_to_hit(hit,complex_derivation)
			# if it doesn't contain the time tag_text
			# then we have to get it from the suggest.
			query = nil
			selected_names = []
			entity_name = nil
			if complex_derivation["tag_text"].blank?
				entity_name = complex_derivation["tags"][0]
			else
				entity_names = complex_derivation["tag_text"].split(SEPARATOR_FOR_TAG_TEXT)[0].split(",")
				selected_names = entity_names.select{|c| query =~ /c/i } unless query.blank?
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
			complex_derivation["stats"][0..-7].each_slice(3) do |year_data|
				#####puts "year data is:"
				#####puts year_data.to_s
				total_up += year_data[1]
				total_down += year_data[2]
			end

			## so there is some issue here.
			## tso problem
			input = entity_name + "#" +  "#{total_up}$$" + complex_derivation["stats"].join("$") + ",#{total_down}" + ",0,0,0,0,0,0,0,0,0,0,0" + complex_derivation["industries"].join(",") + "*#{entity_name.size},0" 

			input_and_impacted_entity_id = plug_industries(input)

			hit = {
				_id: hit["_id"],
				_source: {
					preposition: hit["_source"]["preposition"],
					epoch: hit["_source"]["epoch"],
					tags: hit["_source"]["tags"],
					impacted_entity_id: input_and_impacted_entity_id[:impacted_entity_id],
					suggest: [
						{
							"input" => input_and_impacted_entity_id[:input]
						}
					],
					## debug here.
					trend_direction: complex_derivation["trend_direction"],
					nearest_epoch: complex_derivation["nearest_epoch"],
					epoch_score: complex_derivation["epoch_score"],
					gd_forward_epoch_score: complex_derivation["gd_forward_epoch_score"],
					current_datapoint_epoch: complex_derivation["current_datapoint_epoch"],
					p_val: complex_derivation["p_val"]
				}
			}
			
		end

		## @param[Array: {id, entity_id}]
		def es_find_multi(multiple)
			## so its pretty simple actually.
			body = {
				query: {
					bool: {
						should: [
						]
					}
				}
			}

			multiple.each_with_index{|value,key|
				##puts value.to_s
				body[:query][:bool][:should] << {
					bool: {
						must: [
							{
								ids: {
									values: [value[:id]]
								}
							},
							{
								nested: {
									path: "complex_derivations",
									query: {
										term: {
											"complex_derivations.impacted_entity_id".to_sym => value[:entity_id]
										}
									}
								}
							}
						]
					}
				}
			}

			response = Hashie::Mash.new gateway.client.search :index => "correlations", :type => "result", :body => body
			
			results = []
			response.hits.hits.each do |hit|
				complex_derivations = hit._source.complex_derivations
				results << build_setup(complex_derivation_to_hit(hit,complex_derivations[0]))
			end

			results
		end

  		## here we find by the 
		def es_find(id,args={})
			response = gateway.client.get :id => id, :index => "correlations", :type => "result"
			complex_derivations = response["_source"]["complex_derivations"]
			complex_derivation_index = 0
			unless args[:entity_id].blank?
				complex_derivations.each_with_index{|val,key|
					
				}
			end
			if response["_source"]
				## okay so now for the build_setup part.
				build_setup(complex_derivation_to_hit(response,complex_derivations[complex_derivation_index]))
			end
		end

		###########################################################
		##
		##
		## SERVER SIDE RESULT GENERATION.
		##
		##
		###########################################################
		## @param[Hash] hit
		## @return[Hash] hit, with a setup key.
		## adds the title, description, image url keys, server side.
		def build_setup(hit)
			hit = hit.stringify_keys
			####puts "hit stringified is"
			####puts JSON.pretty_generate(hit)
			search_result = hit['_source']
			#####puts "search result is:"
			#####puts search_result.to_s
			####puts "suggest is:"
			####puts search_result["suggest"].to_s
			offsets = get_offsets(search_result["suggest"][0]["input"]);
			#####puts "ofsets are: #{offsets}"
			suggestion = search_result["suggest"][0];
			#
			#####puts "suggestion is :#{suggestion}"
			related_queries = suggestion["input"].split("%")[1].split("*")[0];
			pre = suggestion["input"].split("%")[0];
			#####puts "pre is :#{pre}"
			information = pre.split("#");
			#####puts "information is: #{information}"
			search_result["information"] = information;
			stats = information[1];
			stats = stats.split(",");
			#####puts "stats are :#{stats}"
			## but then you need the target and everything
			## to be loaded on the server side itself.
			## is this necessary ?
			## 10 yr trends for ?
			## 10 yr trends
			## How does Asian Paints react on Mondays?
			#####puts "information 0 is:" 
			#####puts information[0]
			str = information[0]
			#####puts "str is #{str}"

			string = str[offsets[0]..offsets[1]]
			#####puts "string becomes: #{string}"
			search_result["setup"] = "What happens to " + string;
			search_result["setup"] = search_result["setup"].gsub(/\-/," ");
			search_result["triggered_at"] = search_result["epoch"];
			#####puts JSON.pretty_generate(search_result)

			stats = stats[0..12]

			############ => NEXT PART.

			build_setup_actual(search_result,"");

			search_result["impacts"] = [];	

			impact = {
				statistics: []
			}

			##console.log("setup is:");
			##console.log(search_result.setup);
			##console.log("stats are:");
			##console.log(stats);
			##console.log("-----------------------");

			
			stats[0] = stats[0].split("$$")[0];
			## add week.
			####puts "stats are :#{stats}"
			if((stats[0].to_i == 0) && (stats[1].to_i == 0))

			
			else
				impact[:statistics].push({
					time_frame: 1,
					time_frame_unit: "days",
					time_frame_name: "1 day",
					total_up: stats[0].to_i,
					total_down: stats[1].to_i,
					maximum_profit: stats[2].to_i,
					maximum_loss: stats[3].to_i
				})
				search_result["rises_or_falls"] = get_rises_or_falls(impact[:statistics][0]);
				search_result["percentage"] = get_percentage(impact[:statistics][0]);
				assign_answer(search_result);
				convert_n_day_change_to_superscript(search_result);
				replace_percentage_and_literal_numbers(search_result);
				shrink_indicators(search_result);
				strip_period(search_result);
				add_time_to_setup(search_result);
				## so this should ideally show better shit for indicator.
				## rerun test and see, next step -> backgrounds have to be better.
				## link to the actual paths
				## link to the combination pages
				## how to show multiple search results, is there any good way ?

			end

			## today finish sharing
			## for facebook and twitter with a chart image
			## and navigation ?

			#####puts "the search result becomes finally ------>"
			#####puts JSON.pretty_generate(search_result)

			#####puts "the hit is: "
			#####puts JSON.pretty_generate(hit)

			# i want to design the charts and sort this out.
			# that is end game for this part.
			# then navigation.

			set_social_parameters(hit)
			
			hit
		end

		def get_rises_or_falls(statistic)
			if statistic[:total_up] >= statistic[:total_down]
				return "tends to rise";
			
			else
				return "tends to fall";
			end
		end


		def get_percentage(statistic)
			
			k = nil
			
			total = statistic[:total_up] + statistic[:total_down]
			

			if(statistic[:total_up] >= statistic[:total_down])
				k =  (statistic[:total_up].to_f/total.to_f)*100.to_f.to_i
			
			else
				k = (statistic[:total_down].to_f/total.to_f)*100.to_f.to_i 
			end
			
			k.round
		end


		def mod_prev_tag_and_complex_string(search_result,prev_tag_is_colloquial,complex_string,type)

			search_result["tags"].each_with_index{|tag,index|
				if tag.start_with?("**")
					prev_tag_is_colloquial = 1 if !tag.end_with?("**")
				elsif tag.end_with?("**")
					prev_tag_is_colloquial = 0
				elsif tag.start_with?("**") && tag.end_with?("**")
					## nothing.
				else
					if type == 0
						if index == 0
							complex_string =  complex_string + tag + "'s" + " "
						else
							complex_string = complex_string + tag + " ";
						end
					elsif type == 1
						if prev_tag_is_colloquial == 0 
							complex_string = complex_string + tag + " "
						end
					elsif type == 2
						if prev_tag_is_colloquial == 0
							if index == 0 
								## full name.
								complex_string =  complex_string + tag + "'s" + " ";
							elsif index == 1 
								## symbol
							else 
								complex_string = complex_string + tag + " ";
							end
						end
					end
				end
			}

			{
				prev_tag_is_colloquial: prev_tag_is_colloquial,
				complex_string: complex_string
			}

		end

		## => next part begins.
		def build_setup_actual(search_result,text)

			complex_string = search_result["preposition"] + " ";
			
			#####puts "search result tags are:"
			#####puts search_result["tags"]
		
			## this has to be done better.
			## if the part inside the ** contains the text
			## then we keep it and knock off the other part.
			## this is not going to be easy.
			## same thing is repeated below in the final else.
			if(search_result["tags"].select{|c| c =~ /period_start_\d/i}.size > 0)
					
				#####puts "goes into the first if condition"
				prev_tag_is_colloquial = 0
				## this is being called twice, can be ported to a functional part of the code.
				results = mod_prev_tag_and_complex_string(search_result,prev_tag_is_colloquial,complex_string,0)			
				prev_tag_is_colloquial = results[:prev_tag_is_colloquial]
				complex_string = results[:complex_string]
			else

				#####puts "goes into else"
				#####puts "search result information is:" 
				#####puts search_result["information"]

				if search_result["information"].select{|c| c =~ /first|second|third|fourth|fifth|sixth|seventh|last|year|month|week|quarter|Monday|Tuesday|Wednesday|Thursday|Friday|Saturday|Sunday|January|February|March|April|May|June|July|August|September|October|November|December|20[1-9][1-9]|[0-9](th|st|rd)\b/ }.size > 0 

					#####puts "gets time based subindicator"
					prev_tag_is_colloquial = 0
		 			
		 			results = mod_prev_tag_and_complex_string(search_result,prev_tag_is_colloquial,complex_string,1)			
					
					prev_tag_is_colloquial = results[:prev_tag_is_colloquial]
					
					complex_string = results[:complex_string]

					#####puts "sets complex string to: #{complex_string}"

				elsif(search_result["tags"].select{|c| c =~ /first|second|third|fourth|fifth|sixth|seventh|last|year|month|week|quarter|Monday|Tuesday|Wednesday|Thursday|Friday|Saturday|Sunday|January|February|March|April|May|June|July|August|September|October|November|December|20[1-9][1-9]|[0-9](th|st|rd)\b/ }.size > 0)


					##console.log("got a time based subindicator, by checking the tags");
					search_results.tags.each_with_index{|tag,index|
						if tag.start_with?("**") && tag.end_with?("**")

						else
							complex_string = complex_string + tag + " ";
						end
					}
					
					
				else
					#####puts "came to the last else."
					prev_tag_is_colloquial = 0
		 			
		 			results = mod_prev_tag_and_complex_string(search_result,prev_tag_is_colloquial,complex_string,2)			
					
					prev_tag_is_colloquial = results[:prev_tag_is_colloquial]
					
					complex_string = results[:complex_string] 		
				end

			end

			
			search_result["setup"] = search_result["setup"] + " " + complex_string;	
			search_result["complex_string"] = complex_string;
			assign_target(search_result);
			get_primary_entity_and_indicator(search_result);
			
			##build_meta_description(search_result);
			##add_chart_image_url(search_result);
		end

		## will set search_result["answer"] to 
		def assign_answer(search_result)
			####puts "search result is:"
			####puts search_result.to_s
			search_result["answer"] = "Historically " + search_result["target"] + " tends to " + search_result["rises_or_falls"].to_s + " " + search_result["percentage"].to_s + "%" + " of the times."
		end


		def get_primary_entity_and_indicator(search_result)

			
			search_result["setup"].scan(/when(?<primary_entity>[A-Za-z\s]+)\'s\s(?<indicator>[A-Za-z_\d+]+)\s(?<indicator_suffix>indicator)?/i) do 

				jj = ::Regexp.last_match

				search_result["primary_entity"] = jj[:primary_entity]
				search_result["indicator"] = jj[:indicator]
				unless jj[:indicator_suffix].blank?
					search_result["indicator"] += (" indicator") 
				end

				## so its done, build the fucking meta.

			end
		
		end


		def assign_target(search_result)
			
			search_result["setup"].scan(/to\s(?<target_one>[a-zA-Z0-9\s\-\_]+)\b(in|when|on)\b/) do |q|

				jj = ::Regexp.last_match

				search_result["target"] = jj[:target_one]

				search_result["target"].scan(/(?<target_two>[a-zA-Z0-9\s\-\_]+)\b(in|when|on)\b/) do |j| 

					ll = ::Regexp.last_match

					search_result["target"] = ll[:target_two]

				end

			end
			#####puts "the target it: #{search_result['target']}"

		end


		def get_offsets(input_text)
			split_on_offsets = input_text.split("*");
			text_stats_and_related_queries = split_on_offsets[0];
			offsets = split_on_offsets[1];
			offsets = offsets.split(",").map{|c| c.to_i}.sort
			offsets[1] = offsets[1] + 1
			offsets
		end

		##############################################
		##
		##
		## PORTED
		##
		##
		#############################################
		def convert_n_day_change_to_superscript(search_result)
			days = nil
			search_result["setup"].scan(/(?<days>\d+)\sday\schange/) do |n|
				jj = ::Regexp.last_match
				days = jj[:days]
			end

			search_result["setup"].gsub!(/\d+\sday\schange/,'')
			
			search_result["day_change"] = days.to_s
			
		end

		## and the clock symbol for the date.s
		## okay improve those cards first
		## then the rest of it.
		## basically improve the combinations page
		## go to a combinations page ->
		## show it ->
		## and allow me to paginate it.
		## similar to indicator and entity.
		## show the date in a better way with a clock icon.
		## change the card to show the graph below, and the text above.
		## that would look better.
		## as a summary style.
		## and make the card look like our current card.

		def replace_percentage_and_literal_numbers(search_result)

			search_result["setup"].gsub!(/\w+/){ |match|

				if NUMERIC_LITERALS[match].blank?
					match
				else
					NUMERIC_LITERALS[match]
				end
			}

		end

		def shrink_indicators(search_result)
			search_result["setup"].gsub!(/#{Regexp.escape(Indicator::INDICATOR_NAMES_AND_ABBREVIATIONS.keys.join("|"))}/) { |match|  Indicator::INDICATOR_NAMES_AND_ABBREVIATIONS[match] }
		end

		def strip_period(search_result)
			search_result["setup"].gsub!(/(_period_start_\d+(_\d+)?_period_end)/) { |match|  ""}
		end

		def add_time_to_setup(search_result)
			time = Time.strptime(search_result["triggered_at"].to_s,"%s")
			search_result["setup"] = search_result["setup"]  + " (" + time.strftime('%-d %b %Y') +  ")";
		end


	end

	NUMERIC_LITERALS = {
		"one" => "1",
		"two" => "2",
		"three" => "3",
		"four" => "4",
		"five" => "5",
		"sixty" => "60",
		"six" => "6",
		"ten" => "10",
		"twenty" => "20",
		"thirty" => "30",
		"forty" => "40",
		"fifty" => "50",
		"seventy" => "70",
		"eighty" => "80",
		"ninety" => "90",
		"hundred" => "100",
		"half" => "<sup>1</sup>&frasl;<sup>2</sup>",
		"percent" => "%"
	}

end