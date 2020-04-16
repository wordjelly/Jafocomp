module Concerns::DebugPollerConcern

	extend ActiveSupport::Concern

  	included do

  	end

  	module ClassMethods

  		## we basically want to paginate by poller-session-id
		## find the first one, where saturated was hit
		## check the thing before it and see what is wrong
		## then implement the new logic and see that it does not fail.
		def ps
			query = {
				bool: {
			      	must: [
				        {
				          	exists: {
				            	field: "poller_session_id"
				          	}
				        }
			      	]
			    }
			}

			aggs = {
				poller_session_ids: {
					composite: {
						size: 1000,
						sources: [
							{
					            poller_session_id: {
					              terms: {
					                field: "poller_session_id"
					              }
					            }
					        }
						]
					},
					aggs: {
				        event_name: {
				          terms: {
				            field: "event_name"
				          },
				          aggs: {
				          	information: {
				          		terms: {
				          			field: "information"
				          		}
				          	}
				          }
				        },
				        log_time: {
				          min: {
				            field: "time"
				          }
				        }
			      	}
				}
			}


			## start -> all the things till it ends, should be in its bucket.
			## need a downloader started -> event.
			## and a downloader ended event also ->
			## how many jobs are on, when the 


			response = Hashie::Mash.new gateway.client.search body: {size: 0, query: query, aggs: aggs}, index: "tradegenie_titan", type: "doc"

			## we need like, jobs already on. at this time.
			## and why the decrement has fucked up so badly.
			## key =-> epoch
			## 
			## value =-> hash
			## {poller_session_id => {event_name => count}}
			## 
			poller_sessions_keyed_by_time = {}

			#puts response.to_s

			response.aggregations.poller_session_ids.buckets.each do |bucket|
				poller_session_id = bucket["key"]
				time = bucket["log_time"]["value"]
				information = bucket["log_time"]["information"]
				poller_sessions_keyed_by_time[time.to_s] = {
					poller_session_id.to_s => {
						events: bucket["event_name"]["buckets"]
					}
				}.to_h
			end

			
			poller_sessions_keyed_by_time = poller_sessions_keyed_by_time.sort.to_h

			results = {}

			poller_sessions_keyed_by_time.keys.each do |time|
				poller_sessions_keyed_by_time[time].keys.each do |poller_session_id|
					events = poller_sessions_keyed_by_time[time][poller_session_id][:events]
					#entry_stats = get_entry_memory(events)
					#exit_stats = get_exit_memory(events)
					#why going into -36 suddenly.
					#number of pending jobs ?
					#cycled ?
					# 
					results[time] = [get_entry_memory(events),get_memory_sufficient(events),get_job_status(events),get_exit_memory(events)]
				end
			end

			results.values.each_slice(10) do |slice|
				puts JSON.pretty_generate(slice)
				gets.chomp
			end
		end

		def get_memory_sufficient(events)
			k = events.select{|c|
				c["key"] =~ /memory_sufficient/i
			}
			if k.size > 0
				["sufficient"]
			else
				k = events.select{|c|
					c["key"] =~ /insufficient/i
				}
				if k.size > 0
					["insufficient"]
				else
					nil
				end
			end
		end

		def get_job_status(events)
			k = events.select{|c|
				c["key"] =~ /evicted|pending_job|allowed/i
			}
			if k.size > 0
				k["information"]["buckets"][0]["key"]
			else
				nil
			end
		end

		def get_job_allowed_to_continue(events)
			k = events.select{|c|
				c["key"] =~ /allowed/i
			}
			if k.size > 0
				["continue"]
			else
				nil
			end
		end

		def get_entry_memory(events)
			memory = nil
			pollers_after = nil
			k = events.select{|c|
				c["key"] =~ /activated/i
			}
			if k.size > 0
				k = k[0]
				information = k["information"]["buckets"][0]["key"]
				information.scan(/Available\:\s\d+\.\d\sGiB\/\d+\.\d\sGiB/) do |n|
					memory = n
				end

				information.scan(/pollers_after\"\:\"\d+\"/) do |n|
					pollers_after = n
				end
			end
			[memory,pollers_after]
		end

		def get_exit_memory(events)
			memory = nil
			pollers_after = nil
			information = nil
			k = events.select{|c|
				c["key"] =~ /exiting/i
			}
			if k.size > 0
				k = k[0]
				information = k["information"]["buckets"][0]["key"]
			end
			[memory,information]
		end

		def did_not_exit?(buckets)
			buckets.select{|c|
				c["key"] =~ /exited/i
			}
		end

		def has_saturated_event?(buckets)
			#puts buckets.to_s
			buckets.select{|c|
				c["key"] =~ /saturated/i
			}.size > 0
		end
  		
  	end

end