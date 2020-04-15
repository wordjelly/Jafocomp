module IndividualResultConcern

	extend ActiveSupport::Concern

  	included do

  	end

  	module ClassMethods

  		def set_social_parameters(hit)

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
				#puts "year data is:"
				#puts year_data.to_s
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
							input: input_and_impacted_entity_id[:input]
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
			search_result = hit['_source']
			offsets = get_offsets(search_result["suggest"][0]["input"]);
			#puts "ofsets are: #{offsets}"
			suggestion = search_result["suggest"][0];
			#
			puts "suggestion is :#{suggestion}"
			related_queries = suggestion["input"].split("%")[1].split("*")[0];
			pre = suggestion["input"].split("%")[0];
			#puts "pre is :#{pre}"
			information = pre.split("#");
			#puts "information is: #{information}"
			search_result["information"] = information;
			stats = information[1];
			stats = stats.split(",");
			#puts "stats are :#{stats}"
			## but then you need the target and everything
			## to be loaded on the server side itself.
			## is this necessary ?
			## 10 yr trends for ?
			## 10 yr trends
			## How does Asian Paints react on Mondays?
			#puts "information 0 is:" 
			#puts information[0]
			str = information[0]
			#puts "str is #{str}"

			string = str[offsets[0]..offsets[1]]
			#puts "string becomes: #{string}"
			search_result["setup"] = "What happens to " + string;
			search_result["setup"] = search_result["setup"].gsub(/\-/," ");
			search_result["triggered_at"] = search_result["epoch"];
			#puts JSON.pretty_generate(search_result)

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

			## add week.
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
			end

			## today finish sharing
			## for facebook and twitter with a chart image
			## and navigation ?

			puts "the search result becomes finally ------>"
			puts JSON.pretty_generate(search_result)

			puts "the hit is: "
			puts JSON.pretty_generate(hit)

			## here only we have to set the meta_tags
			## for the result
			## or those can be set via the controller ?
			## 

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
			if(statistic[:total_up] >= statistic[:total_down])
				return ((statistic[:total_up]/(statistic[:total_up] + statistic[:total_down]))*100).round
			
			else
				return ((statistic[:total_down]/(statistic[:total_up] + statistic[:total_down]))*100).round
			end
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
			
		
			## this has to be done better.
			## if the part inside the ** contains the text
			## then we keep it and knock off the other part.
			## this is not going to be easy.
			## same thing is repeated below in the final else.
			if(search_result["tags"].select{|c| c =~ /period_start_\d/i}.size > 0)
				
				prev_tag_is_colloquial = 0
				## this is being called twice, can be ported to a functional part of the code.
				results = mod_prev_tag_and_complex_string(search_result,prev_tag_is_colloquial,complex_string,0)			
				prev_tag_is_colloquial = results[:prev_tag_is_colloquial]
				complex_string = results[:complex_string]
			else

				if search_result["information"] =~ /first|second|third|fourth|fifth|sixth|seventh|last|year|month|week|quarter|Monday|Tuesday|Wednesday|Thursday|Friday|Saturday|Sunday|January|February|March|April|May|June|July|August|September|October|November|December|20[1-9][1-9]|[0-9](th|st|rd)\b/

					prev_tag_is_colloquial = 0
		 			
		 			results = mod_prev_tag_and_complex_string(search_result,prev_tag_is_colloquial,complex_string,1)			
					
					prev_tag_is_colloquial = results[:prev_tag_is_colloquial]
					
					complex_string = results[:complex_string]

				elsif(search_result["tags"].select{|c| c =~ /period_start_\d/i}.size > 0)


					##console.log("got a time based subindicator, by checking the tags");
					search_results.tags.each_with_index{|tag,index|
						if tag.start_with?("**") && tag.end_with?("**")

						else
							complex_string = complex_string + tag + " ";
						end
					}
					
					
				else
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
			puts "the target it: #{search_result['target']}"

		end


		def get_offsets(input_text)
			split_on_offsets = input_text.split("*");
			text_stats_and_related_queries = split_on_offsets[0];
			offsets = split_on_offsets[1];
			offsets = offsets.split(",").map{|c| c.to_i}.sort
			offsets[1] = offsets[1] + 1
			offsets
		end

	end
end