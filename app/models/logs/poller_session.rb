require 'elasticsearch/persistence/model'


## consolidated poller sessions, or proessor sessions.(two colum view.)
## paginate part.
## download session -> click on an exchange, click on an entity, or see its history 
## search by poller session id
## search by poller session date range.

## ----------------------------------------------------------------------

## exchange level -> one row per poller session -> events, list of entities, click on an entity in the events.(two tabs, click on any entity -> its view.)
## entity level -> historical poller session data, and its historical prices.(two tabs)

class Logs::PollerSession

	#include Elasticsearch::Persistence::Model

	INDEX_NAME = "tradegenie_titan"
	DOCUMENT_TYPE = "doc"

	COMMON = [
		"M1-LOCK_ENTERED",
		"M301-LOCK_ENOUGH_MEMORY_PROCEED",
		"M302-LOCK_ENOUGH_MEMORY_IGNORE",
		"M401-LOCK_TURN_PROCEED",
		"M402-LOCK_TURN_IGNORE",
		Concerns::Stock::EntityConcern::FRONTEND_LOG
	]
	
	POLLER_SESSION_EVENTS = [
		"A1a32_NO_JOB",
		"A1a10-POLLER-ERROR"
	]

	DOWNLOADER_SESSION_EVENTS = [
		"A1d03_INDEX_DOWNLOAD_PROCEED",
		"A1d04_INDEX_DOWNLOAD_IGNORE",
		"A1h3-ENTITY_TOO_MUCH_PRICE_CHANGE",
		"A1i-ENTITY_DOWNLOAD_ERROR"
	]

	## we are taking only those events which have this entityid.
	## so we don't need to filter here anymore.
	## indice, entity_unique_name
	def self.aggs(args={})
		## here the pagination is an issue.
		## how do we do this.
		## do it by range query only.
		## that date and time -. should get returned.
		combined = COMMON + POLLER_SESSION_EVENTS + DOWNLOADER_SESSION_EVENTS
		combined.flatten!

		{
		    "poller_session" => {
			    "terms" => {
			        "field" => "poller_session_id",
			        "size" => 200,
			        "order" => {
			          "start_time" => "desc"
			        }
			    },
		      	"aggs" => {
		        	"type" => {
		          		"terms" => {
		            		"field" => "poller_session_type",
		            		"size" => 1
		          		},
		          		"aggs" => {
		            		"events" => {
		              			"terms" => {
		                			"field" => "event_name",
		                			"size" => 11,
		                			"include" => combined, 
		                			"order" => {
		                  				"start_time" => "asc"
		                			}
		              			},
		              			"aggs" => {
		                			"start_time" => {
		                  				"min" => {
		                    				"field" => "time"
		                  				}
		                			}
		              			}
		            		}
		          		}
		        	},
			        "start_time" => {
			          	"min" => {
			           	 	"field" => "time"
			          	}
			        }
		      	}
		    }
		}
	end

	## what about pagination.
	## how do we handle that ?
	## we can have a from parameter.

	def self.query(args={})
		base = {
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

		unless args[:poller_session_id].blank?
			base[:bool][:must] << {
				term: {
					poller_session_id: args[:poller_session_id]
				}
			}
		end

		unless args[:entity_unique_name].blank?
			base[:bool][:must] << {
				term: {
					entity_unique_name: args[:entity_unique_name]
				}
			}
		end

		unless args[:indice].blank?
			base[:bool][:must] << {
				term: {
					indice: args[:indice]
				}
			}
		end

		## so we are getting a date string.
		## and how to paginate.
		unless args[:poller_sessions_upto].blank?
			base[:bool][:must] << {
				range: {
					time: {
						lte: Time.parse(args[:poller_sessions_upto]).to_i*1000
					}
				}
			}
		end


		unless args[:poller_sessions_from].blank?
			base[:bool][:must] << {
				range: {
					time: {
						gte: Time.parse(args[:poller_sessions_from]).to_i*1000
					}
				}
			}
		end

		puts "the query is:"
		puts JSON.pretty_generate(base)

		base

	end

	def self.get(args)
		query = {
			bool: {
				must: []
			}
		}

		args.keys.map{|c|
			query[:bool][:must] << {
				term: {
					c => args[c]
				}
			}
		}

		search_response = Elasticsearch::Persistence.client.search :index => INDEX_NAME, :type => DOCUMENT_TYPE, :body => {
			:size => 0,
			:query => query,
			:aggs => {
				events: {
					terms: {
						field: "event_name",
						size: 100,
						order: {
							"start_time" => "asc"
						}
					},
					aggs: {
						start_time: {
							min: {
								field: "time"
							}
						},
						indices: {
							terms: {
								field: "indice"
							},
							aggs: {
								information: {
									terms: {
										field: "information",
										size: 100,
										order: {
											start_time: "asc"
										}
									},
									aggs: {
										start_time: {
											min: {
												field: "time"
											}
										},
										entity_unique_names: {
											terms: {
												field: "entity_unique_name"
											}
										}
									}
								}	
							}
						}
					}
				}
			}
		}
		
		# indices -> 
		# what is the information that you want on them.
		# is the memory required.
		# newly downloaded date and datapoints.
		# we don't wanna include the memory information under the logs
		# we wanna group the 
		puts "--------------------------------------------------->"
		#puts JSON.pretty_generate(search_response["aggregations"])
		
		puts "--------------------------------------------------->"

		poller_session_rows = search_response["aggregations"]["events"]["buckets"].map {|event_bucket|
			{
				"event_name" => event_bucket["key"],
				"indices" => event_bucket["indices"]["buckets"].map{|c|
					{
						"index_name" => c["key"],
						"information" => c["information"]["buckets"].map{|d|
							{
								"description" => JSON.parse(d["key"]),
								"start_time" => (Time.at(d["start_time"]["value"].to_i/1000).strftime("%-d %b %Y %I:%M:%S %P")),
								"entity_unique_names" => d["entity_unique_names"]["buckets"].map{|un| un["key"]}
							}
						}
					}
				}
			}
		}

		poller_session_rows

		## so we have an expandable/ collapsible system
		## information -> entity unique names(collapse a bit.)
		## so entities inside exchanges, where we can click and filter
		## and we can filter whatever we want also.
	end

	## now can render this on the front end.
	## converts the aggregation to a table.
	## @return[Array]
	## [
	##  {
	##     "start_time" : whatever,
	##     "type" : downloader/poller
	##     "events" : [{"event_name" => x, "event_time" => y}]
	##  }
	##]
	def self.view(args={})

		search_response = Elasticsearch::Persistence.client.search :index => INDEX_NAME, :type => DOCUMENT_TYPE, :body => {
			:size => 0,
			:query => query(args),
			:aggs => aggs(args)
		}
	
		puts JSON.pretty_generate(search_response["aggregations"])
		
		table_rows = []

		search_response["aggregations"]["poller_session"]["buckets"].each do |poller_session_bucket|

			poller_session_id = poller_session_bucket["key"]

			start_time = Time.at(poller_session_bucket["start_time"]["value"].to_i/1000).strftime("%-d %b %Y %I:%M %P")

			poller_session_bucket["type"]["buckets"].each do |type_bucket|

				type = type_bucket["key"]

				events = []

				type_bucket["events"]["buckets"].each do |event_bucket|

					event_time = Time.at(event_bucket["start_time"]["value"].to_i/1000).strftime("%I:%M %P")

					event_name = event_bucket["key"]

					events << {
						"event_time" => event_time,
						"event_name" => event_name
					}

				end

				table_rows << {
					"poller_session_id" => poller_session_id,
					"start_time" => start_time,
					"type" => type,
					"events" => events
				}

			end

		end

		puts JSON.pretty_generate(table_rows)

		table_rows

	end
end