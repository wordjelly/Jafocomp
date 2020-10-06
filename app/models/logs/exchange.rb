require 'elasticsearch/persistence/model'

class Logs::Exchange
	
	include Elasticsearch::Persistence::Model
	
	def self.index_properties
		{
			:name => {
				:type => 'keyword'
			},
			:summary => {
				:type => 'keyword'
			},
			:download_sessions => {
				:type => 'nested',
				:properties => Logs::DownloadSession.bare_properties
			},
			:events => {
				:type => 'nested',
				:properties => Logs::Event.index_properties
			}
		}
	end

	def self.bare_properties
		{
			:name => {
				:type => 'keyword'
			},
			:summary => {
				:type => 'keyword'
			},
			:events => {
				:type => 'nested',
				:properties => Logs::Event.index_properties
			}
		}
	end

	index_name "tradegenie_titan"
	document_type "doc"

	attribute :name, String, mapping: {type: 'keyword'}
	attribute :summary, String, mapping: {type: 'keyword'}
	attribute :download_sessions, Array[Logs::DownloadSession], mapping: {type: 'nested', properties: Logs::DownloadSession.index_properties }
	attribute :events, Array[Logs::Event], mapping: {type: 'nested', properties: Logs::Event.index_properties}

	
	##############################################################
	##############################################################

	def self.query(args={})
		{
			term: {
				indice: args[:exchange_name]
			}
		}
	end

	def self.aggs(args={})
		{
	        "linked_list" => {
	          	"nested" => {
	            	"path" => "es_linked_list"
	          	},
	          	"aggs" => {
	            	"dps" => {
		              	"nested" => {
		                	"path" => "es_linked_list.data_point"
		              	},
	              		"aggs" => {
	                		"datestring" => {
	                  			"terms" => {
	                    			"order" => {
	                      				"_term" => "desc"
	                    			}, 
	                    			"field" => "es_linked_list.data_point.dateString",
	                    			"size" => 10
	                  			},
	                  			"aggs" => {
	                    			"polled_or_not" => {
	                      				"filters" => {
	                        				"other_bucket_key" => "not_polled", 
	                        				"filters" => {
	                          					"poller_session_id" => {
		                            				"exists" => {
		                              					"field" => "es_linked_list.data_point.poller_processor_session_id"
		                            				}
	                          					}
	                        				}
	                      				},
				                      	"aggs" => {
				                        	"entity_name" => {
				                          		"terms" => {
				                            		"field" => "es_linked_list.data_point.entity_unique_name",
				                            		"size" => 10
				                          		}
				                        	}
				                      	}
	                    			},
	                    			"entity_names" => {
	                    				"terms" => {
	                    					"field" => "es_linked_list.data_point.entity_unique_name",
	                    					"size" => 50
	                    				}
	                    			}
	                  			}
	                		}
	              		}
	            	}
	          	}
	        }
		}
	end

	def self.summary(args={})
		
		#puts "----------- triggered exchange summary ----------"

		#puts "query is:"
		#puts JSON.pretty_generate(query(args))

		#puts "aggs are:"
		#puts JSON.pretty_generate(aggs(args))

		#puts "--------------------------------------------------"

		search_response = Elasticsearch::Persistence.client.search :body => {
			query: query(args),
			aggs: aggs(args)
		}, :index => "tradegenie_titan", :type => "doc"

		datapoints = []

		#puts "search response is:"
		#puts JSON.pretty_generate(search_response)


		search_response["aggregations"]["linked_list"]["dps"]["datestring"]["buckets"].each do |date_bucket|

			datapoints << {
				date: date_bucket["key"],
				downloaded: date_bucket["entity_names"]["buckets"].map{|c| c["key"]},
				not_downloaded: args[:entity_unique_names] - date_bucket["entity_names"]["buckets"].map{|c| c["key"]},
				polled: date_bucket["polled_or_not"]["buckets"]["poller_session_id"]["entity_name"]["buckets"].map{|c| c["key"]},
				not_polled: date_bucket["polled_or_not"]["buckets"]["not_polled"]["entity_name"]["buckets"].map{|c| c["key"]}
			}


		end

		datapoints

	end

	def self.all(args={})

		base = {
			bool: {
				must: [
					{
						exists: {
							field: "ohlcv_type"
						}
					}
				]
			}
		}

		## if exchange name is provided then show that.
		## so on and so forth.
		## so we get entities under each exchange.
		if args[:exchange_name]
			base[:bool][:must] << {
				term: {
					indice: args[:exchange_name]
				}
			}
		end

		search_response = Elasticsearch::Persistence.client.search :body => {
			:_source => ["indice","entity_unique_name"],
			:size => 0,
			:query => base,
			:aggs => {
				exchange_names: {
					terms: {
						field: "indice"
					},
					aggs: {
						entity_names: {
							terms: {
								field: "entity_unique_name",
								size: 100
							}
						}
					}
				}
			}
		}, :index => "tradegenie_titan", :type => "doc"


		#puts "search exchanges response"
		#puts JSON.pretty_generate(search_response)
		#puts "------------------------------------"

		exchanges = []
		search_response["aggregations"]["exchange_names"]["buckets"].map{|exchange_bucket|
			exchange_name = exchange_bucket["key"]
			entity_names = exchange_bucket["entity_names"]["buckets"].map{|c| c["key"] }	
			exchanges << {
				name: exchange_name,
				entity_names: entity_names
			}
		}


		exchanges

	end

	## filtered by recent download.
	## 
	DOWNLOAD_HISTORY_EVENTS = ["A1d1-DOWNLOADING_INDEX","A1d11-ENTITY_FILTERED_RECENT_DOWNLOAD","A1a12-INDEX_REJECTED_BY_TIME","A1a12-INDEX_PASSED_BY_TIME"]
	ENTITY_FILTRATION_EVENTS = ["A1d11-ENTITY_FILTERED_RECENT_DOWNLOAD","A1d11-ENTITY_NOT_FILTERED_RECENT_DOWNLOAD"]


	def self.download_history_query(args={})
		{
			bool: {
				must: [
					{
						term: {
							indice: args[:exchange_name]
						}
					},
					{
						terms: {
							event_name: DOWNLOAD_HISTORY_EVENTS
						}
					}
				]
			}
		}
	end

	## by poller session.
	def self.download_history_aggregation(args={})
		{
	    	entities: {
	      		terms: {
	        		field: "entity_unique_name",
	        		size: 10,
	        		exclude: ["all_entities"]
	      		},
		      	aggs: {
		      		last_10_poller_sessions: {
		      			terms: {
		      				field: "poller_session_id",
		      				order: {
		      					download_session_time: "desc"
		      				}
		      			},
		      			aggs: {
		      				download_events: {
		      					terms: {
		      						field: "event_name",
		      						include: DOWNLOAD_HISTORY_EVENTS
		      					}
		      				},
		      				filtration_events: {
		      					terms: {
		      						field: "event_name",
		      						include: ENTITY_FILTRATION_EVENTS
		      					},
		      					aggs: {
		      						entities: {
		      							terms: {
		      								field: "entity_unique_name",
		      								size: 50
		      							},
		      							aggs: {
		      								details: {
		      									terms: {
		      										field: "information"
		      									}
		      								}
		      							}
		      						}
		      					}
		      				},
		      				download_session_time: {
		      					min: {
		      						field: "download_session_time"
		      					}
		      				}
		      			}
		      		}
		      	}
		    }
		}
	end

	## @return[ARray]
	## [
	##		{ :poller_session_id => "", :events => [{"event_name" => ["event_info"]}] }
	## ]
	## after this why filtration is still active.
	## it doesnt download anything, so it doesnt do anything
	def self.download_history(args={})
		## so right now we just show this much.
		## and why this is not working in the first place.
		search_response = Elasticsearch::Persistence.client.search :index => "tradegenie_titan", :type => "doc", :body => {
			size: 0,
			query: download_history_query(args),
			aggs: download_history_aggregation(args)
		}

		poller_sessions = []
		search_response["aggregations"]["last_10_poller_sessions"]["buckets"].each do |poller_session_bucket|
			poller_session_id = poller_session_bucket["key"]
			poller_session_time = poller_session_bucket["download_session_time"]["value"]
			events = {}
			events.merge!(poller_session_bucket["download_events"]["buckets"].map{|c| [c["key"],[c["key"]]]}.to_h)

			## this is an event and in it we want the entity names.
			poller_session_bucket["filtration_events"]["buckets"].each do |filtration_event|
				event_name = filtration_event["key"]
				filtration_event["buckets"].each do |event_bucket|
					entity_names = event_bucket["entities"]["buckets"].map{|e| e["key"]}
				end
				events[event_name] = entity_names
			end
			poller_sessions << {:poller_session_id => poller_session_id, :events => events, :poller_session_date => poller_session_time}
		end

		poller_sessions

	end
	

end
