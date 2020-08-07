require 'elasticsearch/persistence/model'

class Logs::PollerSession

	include Elasticsearch::Persistence::Model

	COMMON = [
		"M1-LOCK_ENTERED",
		"M301-LOCK_ENOUGH_MEMORY_PROCEED",
		"M302-LOCK_ENOUGH_MEMORY_IGNORE",
		"M401-LOCK_TURN_PROCEED",
		"M402-LOCK_TURN_IGNORE"
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
		{
		    "poller_session" => {
			    "terms" => {
			        "field" => "poller_session_id",
			        "size" => 100,
			        "order" => {
			          "start_time" => "asc"
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
		                			"size" => 10,
		                			"include" => [], 
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

	

end