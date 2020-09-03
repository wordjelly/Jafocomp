require 'elasticsearch/persistence/model'

class Logs::Entity
	
	include Elasticsearch::Persistence::Model

	attribute :name, String

	attribute :count, Integer

	attribute :information, Array

	index_name "tradegenie_titan"
	document_type "doc"

	def self.index_properties
		{
			:name => {
				:type => 'keyword'
			},
			:count => {
				:type => 'integer'
			},
			:information => {
				:type => 'keyword'
			}
		}
	end

	def self.entities_query(args)
		{
			bool: {
				must: [
					{
						term: {
							indice: args[:exchange_name]
						}
					}
				]
			}
		}
	end

	## so we can click to get an entities download history.
	## to get the idea of what has been happening with it.
	## by time.
	## so on clicking on an entity -> we can get its download history.

	def self.entities_aggregation(args)
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
		      						include: ["A1e-DOWNLOADING_ENTITY","A1i-ENTITY_DOWNLOAD_ERROR","A1h-ENTITY_FORCE_REDOWNLOAD","A1g-ENTITY_EXPECTED_DATAPOINT_ABSENT","A1f-ENTITY_DOWNLOADED_DATE_AND_DATAPOINTS","A1j-ENTITY_NO_NEW_DATAPOINTS"]
		      					}
		      				},
		      				download_session_time: {
		      					min: {
		      						field: "download_session_time"
		      					}
		      				}
		      			}
		      		},
		        	last_10_hits: {
		          		nested: {
		            		path: "es_linked_list"
		          		},
			          	aggs: {
			            	last_10: {
			              		top_hits: {
			                		sort: [
				                  		{
				                    		"es_linked_list.day_id" => {
				                      			order: "desc"
				                    		}	
				                  		}
			                		], 
			                		size: 10,
			                		_source: ["es_linked_list.data_point.close","es_linked_list.data_point.open","es_linked_list.data_point.low","es_linked_list.data_point.high","es_linked_list.data_point.volume","es_linked_list.data_point.day_of_month","es_linked_list.data_point.month_of_year","es_linked_list.data_point.year","es_linked_list.data_point.poller_session_id","es_linked_list.data_point.poller_session_date"
			                		]
			              		}
			            	}
			      		}
		        	}
		      	}
	    	}
		}
	end

	# the argumen has the download history.
	# what about frontend update ?
	# was it successfull or not.
	# this can be combined.
	# add the frontend update things to it.
	def self.download_history_query(args={})
		{
			bool: {
				must: [
					{
						term: {
							entity_unique_name: args[:entity_unique_name]
						}
					}
				]
			}
		}
	end

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
		      						include: ["A1e-DOWNLOADING_ENTITY","A1i-ENTITY_DOWNLOAD_ERROR","A1h-ENTITY_FORCE_REDOWNLOAD","A1g-ENTITY_EXPECTED_DATAPOINT_ABSENT","A1f-ENTITY_DOWNLOADED_DATE_AND_DATAPOINTS","A1j-ENTITY_NO_NEW_DATAPOINTS"]
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

	def self.download_history(args={})

		search_response = Elasticsearch::Persistence.client.search :body => {
			size: 0,
			query: download_history_query(args),
			aggs: download_history_aggregation(args)
		}

		puts "download history search response aggregation is:"
		puts JSON.pretty_generate(search_response["aggregations"])

		entity_bucket = search_response["aggregations"]["entities"]["buckets"][0]

		poller_sessions = []
		entity_bucket["last_10_poller_sessions"]["buckets"].each do |poller_session|
			poller_sessions << {
				:poller_session_id => poller_session["key"],
				:poller_session_date => poller_session["download_session_time"]["value_as_string"],
				:events => poller_session["download_events"]["buckets"].map{|c| c["key"]}
			}
		end

		poller_sessions
	end

	## returns an array of entities, with entity_unique_name and datapoints.
	def self.ticks(args={})
		
		## how to get last download attempt on all entities of this index
		## how to get
		## store the last download attempt on the entity itself, with the result ?
		## then we go for date.
		## and debugging of indicators.
		search_response = Elasticsearch::Persistence.client.search :body => {
			size: 0,
			query: entities_query(args),
			aggs: entities_aggregation(args)
		}

		puts JSON.pretty_generate(search_response["aggregations"])

		entities = []
		## we need poller session id integrated into this.
		## for correlations.
		search_response["aggregations"]["entities"]["buckets"].each do |entity_bucket|
			entity = {"entity_unique_name" => entity_bucket["key"], "datapoints" => []}
			entity_bucket["last_10_hits"]["last_10"]["hits"]["hits"].each do |hit|
				datapoint = hit["_source"]["data_point"]
				entity["datapoints"] << datapoint
			end
			entities << entity
		end

		entities

		puts JSON.pretty_generate(entities)

		entities

	end		

end