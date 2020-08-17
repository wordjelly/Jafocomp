require 'elasticsearch/persistence/model'

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

	def self.aggs
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

	def self.query
		{
			exists: {
				field: "poller_session_id"
			}
		}
	end


	def self.get(poller_session_id)
		search_response = Elasticsearch::Persistence.client.search :index => INDEX_NAME, :type => DOCUMENT_TYPE, :body => {
			:size => 0,
			:query => {
				term: {
					poller_session_id: poller_session_id
				}
			},
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
								}
							}
						}
					}
				}
			}
		}
		
		puts "--------------------------------------------------->"
		puts JSON.pretty_generate(search_response["aggregations"])
		
		puts "--------------------------------------------------->"

		poller_session_rows = search_response["aggregations"]["events"]["buckets"].map {|event_bucket|
			{
				"event_name" => event_bucket["key"],
				"information" => event_bucket["information"]["buckets"].map{|d|
					{
						"description" => JSON.parse(d["key"]),
						"start_time" => (Time.at(d["start_time"]["value"].to_i/1000).strftime("%-d %b %Y %I:%M:%S %P"))
					}
				}
			}
		}

		poller_session_rows

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
	def self.view

		search_response = Elasticsearch::Persistence.client.search :index => INDEX_NAME, :type => DOCUMENT_TYPE, :body => {
			:size => 0,
			:query => query,
			:aggs => aggs
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