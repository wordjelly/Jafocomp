class Logs::Log

	EXCHANGE_NAMES = ["FTSE_100","DAX","CAC_40","NASDAQ-100","NIFTY"]
	ENTITY_TYPE = "entity"
	REDIS_DOWNLOAD_RUNNING = "A1a1-DOWNLOAD_RUNNING"
	REDIS_DOWNLOAD_NOT_RUNNING = "A1a2-DOWNLOAD_NOT_RUNNING"
	REDIS_JOB_PUBLISHER_LIST_EMPTY = "A1a3-JOB_PUBLISHER_LIST_EMPTY"
	REDIS_JOB_PUBLISHER_LIST_NOT_EMPTY = "A1a4-JOB_PUBLISHER_LIST_NOT_EMPTY"
	REDIS_POLLERS_SATURATED = "A1a5_POLLERS_SATURATED"
	REDIS_POLLER_ACTIVATED = "A1a6_POLLERS_ACTIVATED"
	REDIS_POLLERS_RACE_CONDITION = "A1a7_POLLERS_RACE_CONDITION"
	REDIS_POLLER_EXITING = "A1a8_POLLER_EXITING"
	REDIS_DOWNLOAD_EXITING = "A1a9-DOWNLOAD_EXITING"
	POLLER_ERROR = "A1a10-POLLER-ERROR"
	INDEX_EXISTS = "A1a-INDEX_EXISTS"
	BUILDING_INDEX = "A1b-BUILDING_INDEX_FOR_FIRST_TIME"
	BUILT_INDEX = "A1c-BUILT_INDEX_FOR_FIRST_TIME_COMPLETED"
	CHECKING_TIME_BASED_SUBINDICATORS = 
			"A1c1-CHECKING_TIME_BASED_SUBINDICATORS"
	MISCELLANEOUS_DEBUG = "A1z-MISCELLANEOUS_DEBUG"
	TIME_BASED_SUBINDICATORS_EXIST = 
			"A1c2-TIME_BASED_SUBINDICATORS_EXIST"
	TIME_BASED_SUBINDICATORS_ABSENT = 
			"A1c3-TIME_BASED_SUBINDICATORS_ABSENT"
	CALCULATING_TIME_BASED_SUBINDICATORS = 
			"A1c4-CALCULATING_TIME_BASED_SUBINDICATORS"
	COMMITTED_TIME_BASED_SUBINDICATORS = 
			"A1c5-COMMITTED_TIME_BASED_SUBINDICATORS"
	FAILED_TO_COMMIT_TIME_BASED_SUBINDICATORS =
			"A1c6-FAILED_TO_COMMIT_TIME_BASED_SUBINDICATORS"
	ENTITY_EXISTING_DATE_AND_DATAPOINTS = "A1d-ENTITY_EXISTING_DATE_AND_DATAPOINTS"
	DOWNLOADING_INDEX = "A1d1-DOWNLOADING_INDEX"
	ENTITY_DOWNLOADING = "A1e-DOWNLOADING_ENTITY"
	ENTITY_DOWNLOADED_DATE_AND_DATAPOINTS = 
			"A1f-ENTITY_DOWNLOADED_DATE_AND_DATAPOINTS"
	ENTITY_EXPECTED_DATAPOINT_ABSENT = 
			"A1g-ENTITY_EXPECTED_DATAPOINT_ABSENT"
	ENTITY_FORCE_REDOWNLOAD = "A1h-ENTITY_FORCE_REDOWNLOAD"
	ENTITY_FORCE_REDOWNLOAD_datapoint_attribute_mismatch = "A1h1-ENTITY_FORCE_REDOWNLOAD_DATAPOINT_ATTRIBUTE_MISMATCH"
	ENTITY_FORCE_REDOWNLOAD_invalid_datapoint_exists = "A1h2-ENTITY_FORCE_REDOWNLOAD_INVALID_DATAPOINT"
	ENTITY_DOWNLOAD_ERROR = "A1i-ENTITY_DOWNLOAD_ERROR"
	ENTITY_NO_NEW_DATAPOINTS = "A1j-ENTITY_NO_NEW_DATAPOINTS"
	ENTITY_FILTERING = "A1k-ENTITY_FILTERING"
	ENTITY_PRICE_CHANGE_ARRAYS_BEFORE_CALCULATION = 
			"A1l-ENTITY_PRICE_CHANGE_ARRAYS_BEFORE_CALCULATION"
	ENTITY_PRICE_CHANGE_ARRAYS_AFTER_CALCULATION = 
			"A1m-ENTITY_PRICE_CHANGE_ARRAYS_AFTER_CALCULATION"
	ENTITY_STOP_LOSS_ARRAYS_CHANGES = 
			"A1n-ENTITY_STOP_LOSS_ARRAYS_CHANGES"
	ENTITY_UPDATING_STOP_LOSS_AND_PRICE_CHANGE_ARRAYS_TO_ES = "A1o-ENTITY_UPDATING_STOP_LOSS_AND_PRICE_CHANGE_ARRAYS_TO_ES"
	ENTITY_STOP_LOSS_AND_PRICE_CHANGE_ARRAYS_CHUNKS_UPDATED = "A1p-ENTITY_STOP_LOSS_AND_PRICE_CHANGE_ARRAYS_CHUNKS_UPDATED"
	ENTITY_FIRST_NEWLY_DOWNLOADED_PAIR_INDEX_MISSING = 
			"A1q-ENTITY_FIRST_NEWLY_DOWNLOADED_PAIR_INDEX_MISSING"
	FAILED_TO_SHUTDOWN_BULK_PROCESSORS = 
			"A1r-FAILED_TO_SHUTDOWN_BULK_PROCESSORS"
	DOWNLOADED_INDEX = "A1r1-DOWNLOADED_INDEX"
	PUSHED_TO_JOB_PUBLISHER_LIST = "A1r1a-PUSHED_JOB"
	CALCULATING_INDICATORS = "A1r2-CALCULATING_INDICATORS"
	ENTITY_CALCULATING_INDICATOR = "A1r3-ENTITY_CALCULATING_INDICATOR"
	CALCULATING_COMPLEXES = "A1r4-CALCULATING_COMPLEXES"
	COMPLEX_CALCULATION_TASKS_ADDED = "A1r5-COMPLEX_CALCULATION_TASKS_ADDED"
	ENTITY_TASK_STARTED = "A1s-ENTTIY_TASK_STARTED"
	ENTITY_TASK_ERROR = "A1s-ENTTIY_TASK_ERROR"
	ENTITY_TASK_FINISHED = "A1t-ENTITY_TASK_FINISHED"
	FUTURES_RETRIEVED = "A1t1-FUTURES_RETRIEVED"
	FUTURE_RETRIEVE_ERROR = "A1t2-FUTURE_RETRIEVE_ERROR"
	EXECUTOR_WAITING_TO_SHUTDOWN = "A1t3-EXECUTOR_WAITING_TO_SHUTDOWN"
	EXECUTOR_SHUTDOWN_COMPLETED = "A1t4-EXECUTOR_SHUTDOWN_COMPLETED"
	STARTED_BUILDING_CORRELATIONS = "A1u-STARTED_BUILDING_CORRELATIONS"
	CREATED_CORRELATION_INDEX = "A1u1-CREATED_CORRELATION_INDEX"
	TOTAL_TIME_BASED_CORRELATIONS_WITH_INDIVIDUAL_ENTITIES = "A1u2-TOTAL_TIME_BASED_CORRELATIONS_WITH_INDIVIDUAL_ENTITIES"
	CURRENT_TIME_BASED_CORRELATIONS_WITH_INDIVIDUAL_ENTITIES = 
	"A1u3-CURRENT_TIME_BASED_CORRELATIONS_WITH_INDIVIDUAL_ENTITIES"
	TOTAL_COMPLEXES = "A1u4-TOTAL_COMPLEXES"
	CURRENT_CORRELATION_BEING_CALCULATED = 
			"A1u5-CURRENT_CORRELATION_BEING_CALCULATED"
	BUILDING_TIME_BASED_CORRELATIONS = "A1v-BUILDING_TIME_BASED_CORRELATIONS"
	PROCESSING_COMPLEX_QUEUE = "A1v1-PROCESSING_COMPLEX_QUEUE"
	BUILT_CORRELATION_FOR_ENTITY = "A1u2-BUILT_CORRELATION_FOR_ENTITY"
	BUILD_CORRELATION_ERROR = "A1u3-BUILD_CORRELATION_ERROR"
	DOWNLOAD_CRON = "DOWNLOAD_CRON"
	POLLER_CRON = "POLLER_LAST_CRON"


	def self.get_crons

		
		query = {
			terms: {
				event_name: [DOWNLOAD_CRON,POLLER_CRON]
			}
		}
		
		search_response = Elasticsearch::Persistence.client.search :body => {
			query: query,
			aggs: {
				cron_type: {
					terms: {
						field: "event_name",
						size: 2
					},
					aggs: {
						top_hits: {
							top_hits: {}
						}
					}
				}
			},
			size: 0
		}, :index => "tradegenie_titan", :type => "doc"

		download_cron = nil
		
		poller_cron = nil

		puts "crons search response is ------------------->"

		puts JSON.pretty_generate(search_response)

		puts "----------------------------- ENDS ---------- "

		search_response["aggregations"]["cron_type"]["buckets"].each do |cron_type_bucket|
			puts "cron type bucket is:"
			puts cron_type_bucket.to_s 
			puts "------------------------------------>"
			if cron_type_bucket["key"] == DOWNLOAD_CRON
				download_cron = cron_type_bucket["top_hits"]["hits"]["hits"][0]["_source"]
			elsif cron_type_bucket["key"] == POLLER_CRON
				poller_cron = cron_type_bucket["top_hits"]["hits"]["hits"][0]["_source"]
			end
		end

		{:poller_cron => poller_cron, :download_cron => download_cron}

	end

	## what is in the redis list pending to process
	def self.get_queue
		get_response = Elasticsearch::Persistence.client.get :id => "entities_in_list", :type => "doc", :index => "tradegenie_titan"

		document = get_response["_source"].merge("id" => get_response["_id"])

		#puts "QUEUE DOCUMENT IS:"
		#puts document.to_s

		queue = JSON.parse(document["information"])
		queue.map!{|c|
			c["time"] = document["time"]
			c
		}

		queue
	end

	## then market timing based filtering, 
	## next download time scheduled for the exchange.

end