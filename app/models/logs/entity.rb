require 'elasticsearch/persistence/model'

class Logs::Entity
	
	include Elasticsearch::Persistence::Model

	attribute :name, String

	attribute :count, Integer

	attribute :information, Array

	index_name "tradegenie_titan"
	document_type "doc"

	STARTED_ENTITY_POLL_PROCESS = "A1s0-ENTITY_STARTED_POLL_PROCESS";
	ENTITY_TASK_STARTED = "A1s-ENTTIY_TASK_STARTED";
	ENTITY_TASK_ERROR = "A1s-ENTTIY_TASK_ERROR";
	TASK_INFO = "A1z1a-TASK_INFO";
	ENTITY_TASK_FINISHED = "A1t-ENTITY_TASK_FINISHED";
	FUTURES_RETRIEVED = "A1t1-FUTURES_RETRIEVED";
	FUTURE_RETRIEVE_ERROR = "A1t2-FUTURE_RETRIEVE_ERROR";
	EXECUTOR_WAITING_TO_SHUTDOWN = "A1t3-EXECUTOR_WAITING_TO_SHUTDOWN";
	EXECUTOR_SHUTDOWN_COMPLETED = "A1t4-EXECUTOR_SHUTDOWN_COMPLETED";
	FRONTEND_UPDATE = "A1u1a-FRONTEND_UPDATE";
	COMPLEX_PAIR = "A1u2-COMPLEX_PAIR";

	FRONTEND_LOG = "frontend_log"
	LOG_INDEX_NAME = "tradegenie_titan"
	LOG_INDEX_TYPE = "doc"
	LOG_INDEX_POLLER_SESSION_TYPE = "Poller"

	START_FRONTEND_UPDATE = "start_frontend_update"
	FRONTEND_UPDATE_AUTH_ERRPR = "frontend_update_auth_error"
	FRONTEND_UPDATE_ERROR = "frontend_update_error"	
	FRONTEND_UPDATE_COMPLETED = "frontend_update_completed"
	START_BACKGROUND_UPDATE = "start_background_update"
	BACKGROUND_UPDATE_ERROR = "background_update_error"
	BACKGROUND_UPDATE_COMPLETED = "background_update_completed"

	FRONTEND_EVENTS = [START_FRONTEND_UPDATE,FRONTEND_UPDATE_AUTH_ERRPR,FRONTEND_UPDATE_ERROR,FRONTEND_UPDATE_COMPLETED,START_BACKGROUND_UPDATE,BACKGROUND_UPDATE_ERROR,BACKGROUND_UPDATE_COMPLETED]


	POLLER_EVENTS = [STARTED_ENTITY_POLL_PROCESS,ENTITY_TASK_STARTED,ENTITY_TASK_ERROR,ENTITY_TASK_FINISHED,FUTURES_RETRIEVED,FUTURE_RETRIEVE_ERROR,EXECUTOR_WAITING_TO_SHUTDOWN,EXECUTOR_SHUTDOWN_COMPLETED,FRONTEND_UPDATE,COMPLEX_PAIR]


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

	###########################################################
	##
	##
	##
	## FRONTEND UPDATE LOGGING DETAILS.
	##
	##
	##
	###########################################################
	def self.frontend_auth_error(args={})
		create_response = Elasticsearch::Persistence.client.create :index => LOG_INDEX_NAME, :type => LOG_INDEX_TYPE, :id => SecureRandom.uuid, :body => {
				:event_name => FRONTEND_UPDATE_AUTH_ERRPR,
				:time => Time.now.to_i*1000
			}
	end

	def self.start_frontend_update(args={})
		create_response = Elasticsearch::Persistence.client.create :index => LOG_INDEX_NAME, :type => LOG_INDEX_TYPE, :id => SecureRandom.uuid, :body => args.merge({
				:event_name => START_FRONTEND_UPDATE,
				:time => Time.now.to_i*1000
			})
	end

	def self.frontend_update_errors(args={})
		create_response = Elasticsearch::Persistence.client.create :index => LOG_INDEX_NAME, :type => LOG_INDEX_TYPE, :id => SecureRandom.uuid, :body => args.merge({:event_name => FRONTEND_UPDATE_ERROR, :time => Time.now.to_i*1000})
	end

	def self.frontend_update_completed(args={})
		create_response = Elasticsearch::Persistence.client.create :index => LOG_INDEX_NAME, :type => LOG_INDEX_TYPE, :id => SecureRandom.uuid, :body => args.merge({:event_name => FRONTEND_UPDATE_COMPLETED, :time => Time.now.to_i*1000})
	end

	def self.start_background_update(args={})
		create_response = Elasticsearch::Persistence.client.create :index => LOG_INDEX_NAME, :type => LOG_INDEX_TYPE, :id => SecureRandom.uuid, :body => args.merge({
				:event_name => START_BACKGROUND_UPDATE,
				:time => Time.now.to_i*1000
			})	
	end

	def self.background_update_errors(args={})
		create_response = Elasticsearch::Persistence.client.create :index => LOG_INDEX_NAME, :type => LOG_INDEX_TYPE, :id => SecureRandom.uuid, :body => args.merge({
				:event_name => BACKGROUND_UPDATE_ERROR,
				:time => Time.now.to_i*1000
			})		
	end

	def self.background_update_completed(args={})
		create_response = Elasticsearch::Persistence.client.create :index => LOG_INDEX_NAME, :type => LOG_INDEX_TYPE, :id => SecureRandom.uuid, :body => args.merge({
				:event_name => BACKGROUND_UPDATE_COMPLETED,
				:time => Time.now.to_i*1000
			})			
	end

=begin
:entity_unique_name => args[:entity].entity_unique_name,
:indice => args[:entity].indice,
:poller_session_id => self.poller_session_id,
:poller_session_type => LOG_INDEX_POLLER_SESSION_TYPE,
:information => "x/y/z",
=end
	

	##########################################################


	def self.entities_query(args)
		#puts "args coming into entities querys are:"
		#puts args.to_s
		
		base = {
			bool: {
				must: []
			}
		}

		if args[:entity_unique_name]
			base[:bool][:must] << {
				term: {
					unique_name: args[:entity_unique_name]
				}
			}
		end

		if args[:exchange_name]
			base[:bool][:must] << {
				term: {
					indice: args[:exchange_name]
				}
			}
		end

		base
	end

	## so we can click to get an entities download history.
	## to get the idea of what has been happening with it.
	## by time.
	## so on clicking on an entity -> we can get its download history.
	## we want query -> where error is there(event_name)
	## and then aggregate those on poller_session_id.
	## sorted descending.
	def self.entities_aggregation(args)
		{
	    	entities: {
	      		terms: {
	        		field: "entity_unique_name",
	        		size: 10,
	        		exclude: ["all_entities"]
	      		},
		      	aggs: {
		      		entity_id: {
		      			terms: {
		      				field: "_id"
		      			}
		      		},
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
			                		_source: ["es_linked_list.data_point.close","es_linked_list.data_point.open","es_linked_list.data_point.low","es_linked_list.data_point.high","es_linked_list.data_point.volume","es_linked_list.data_point.day_of_month","es_linked_list.data_point.month_of_year","es_linked_list.data_point.year","es_linked_list.data_point.poller_session_id","es_linked_list.data_point.poller_session_date","es_linked_list.data_point.poller_processor_session_id","es_linked_list.data_point.poller_processor_session_date","es_linked_list.data_point.datapoint_index","es_linked_list.data_point.price_change_verified"
			                		]
			              		}
			            	}
			      		}
		        	}
		      	}
	    	}
		}
	end

	DOWNLOAD_HISTORY_EVENTS = ["A1e-DOWNLOADING_ENTITY","A1i-ENTITY_DOWNLOAD_ERROR","A1h-ENTITY_FORCE_REDOWNLOAD","A1g-ENTITY_EXPECTED_DATAPOINT_ABSENT","A1f-ENTITY_DOWNLOADED_DATE_AND_DATAPOINTS","A1j-ENTITY_NO_NEW_DATAPOINTS","A1d11-ENTITY_FILTERED_RECENT_DOWNLOAD"]
	# the argumen has the download history.
	# what about frontend update ?
	# was it successfull or not.
	# this can be combined.
	# add the frontend update things to it.
	# this is good enough to solve this
	# now display the error better.
	def self.download_history_query(args={})
		{
			bool: {
				must: [
					{
						term: {
							entity_unique_name: args[:entity_unique_name]
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

		#puts "download history search response aggregation is:"
		#puts JSON.pretty_generate(search_response["aggregations"])

		entity_bucket = search_response["aggregations"]["entities"]["buckets"][0]

		poller_sessions = []
		entity_bucket["last_10_poller_sessions"]["buckets"].each do |poller_session|
			puts "poller session is====>"
			puts JSON.pretty_generate(poller_session)
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
		#puts "the entities query is:"
		#puts JSON.pretty_generate(entities_query(args))
		#puts "-----------------------------------------"
		search_response = Elasticsearch::Persistence.client.search :body => {
			size: 0,
			query: entities_query(args),
			aggs: entities_aggregation(args)
		}, :index => "tradegenie_titan", :type => "doc"

		##puts JSON.pretty_generate(search_response["aggregations"])

		entities = []
		## we need poller session id integrated into this.
		## for correlations.
		## how to get datapoint index out of this shit.
		## just store it on the datapoint.
		search_response["aggregations"]["entities"]["buckets"].each do |entity_bucket|
			entity = {"entity_unique_name" => entity_bucket["key"], "datapoints" => [], "entity_id" => entity_bucket["entity_id"]["buckets"][0]["key"]}
			entity_bucket["last_10_hits"]["last_10"]["hits"]["hits"].each do |hit|
				datapoint = hit["_source"]["data_point"]
				entity["datapoints"] << datapoint
			end
			entities << entity
		end

		#entities
		puts "------------- ENTITY TICKS ------------------ "
		puts JSON.pretty_generate(entities)

		entities

	end		

	## we can do this with indice also, but at least at the entity level we have it.
	def self.errors(args={})
		query = {
			:bool => {
				:must => [
					{
						:terms => {
							event_name: ["A1i-ENTITY_DOWNLOAD_ERROR","A1s-ENTTIY_TASK_ERROR"]
						}
					}
				]
			}
		}

		if args[:entity_unique_name]
			query[:bool][:must] << {
				term: {
					entity_unique_name: args[:entity_unique_name]
				}
			}
		end

		search_response = Elasticsearch::Persistence.client.search :body => {
			:_source => ["poller_session_id","information","time","event_name"],
			:size => 10,
			:from => args[:from] || 0,
			:query => query
		}
		errors = []
		search_response["hits"]["hits"].each do |hit|
			errors << hit["_source"]
		end
		#puts "entity errors are:"
		#puts JSON.pretty_generate(errors)
		errors
	end

	## we basically want a list of poller events.
	## aggregated by poller session id.
	## use from and to logic as usual.
	def self.poller_history(args={})

		base = {
			bool: {
				must: [
					:terms => {
						event_name: (POLLER_EVENTS + FRONTEND_EVENTS).flatten
					}
				]
			}
		}

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

		unless args[:entity_unique_name].blank?
			base[:bool][:must] << {
				term: {
					entity_unique_name: args[:entity_unique_name]
				}
			}
		end

		search_response = Elasticsearch::Persistence.client.search :body => {
			:_source => ["poller_session_id","information","time","event_name","entity_unique_name","indice"],
			:size => 0,
			:from => args[:from] || 0,
			:query => base,
			:aggs => Logs::PollerSession.aggs(:event_names => (POLLER_EVENTS + FRONTEND_EVENTS).flatten)
		}

		#puts "poller history search response is:"
		#puts JSON.pretty_generate(search_response)
		#puts "------------------------------------------------"

		Logs::PollerSession.parse_poller_sessions_aggs({:search_response => search_response})

	end

end