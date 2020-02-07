require 'elasticsearch/persistence/model'

class Logs::DownloadSession

	include Elasticsearch::Persistence::Model
	
	def self.index_properties
		{
			:epoch => {
				:type => 'date',
				:format => 'epoch_millis'
			},
			:exchanges => {
				:type => 'nested',
				:properties => Logs::Exchange.index_properties
			},
			:events => {
				:type => 'nested',
				:properties => Logs::Event.index_properties
			}
		}
	end

	def self.bare_properties
		{
			:epoch => {
				:type => 'date',
				:format => 'epoch_millis'
			},
			:events => {
				:type => 'nested',
				:properties => Logs::Event.index_properties
			}
		}
	end

	index_name "tradegenie_titan"
	
	document_type "doc"

	attribute :epoch, Date, mapping: {type: 'date', format: 'epoch_millis'}

	attribute :human_readable_date, String
	
	attribute :exchanges, Array[Logs::Exchange], mapping: {type: 'nested', properties: Logs::Exchange.index_properties}

	attribute :events, Array[Logs::Event], mapping: {type: 'nested', properties: Logs::Event.index_properties }

	def self.body(options={})
		query = {
			"bool" => {
		      "must_not" => [
		        {
		          "terms" => {
		            "type" => [
		              "entity",
		              "indicator",
		              "subindicator"
		            ]
		          }
		        }
		      ]
		    }
		}	

		unless options["exchanges"].blank?
			query["bool"]["must"] ||= []
			query["bool"]["must"] << {
				"terms" => {
					"entity_index" => options["exchanges"]
				}
			}
		end

		unless options["entities"].blank?
			query["bool"]["must"] ||= []
			query["bool"]["must"] << {
				"terms" => {
					"entity_unique_name" => options["entities"]
				}
			}
		end		

		puts "query is:"
		puts query.to_s
			
		{
		  "query" => query,
		  "aggs" => {
		    "download_sessions" => {
		      "terms" => {
		        "field" => "download_session_time",
		        "size" => 10,
		        "order" => { "_key" => "desc" }
		      },
		      "aggs" => {
		        "exchanges" => {
		          "terms" => {
		            "field" => "entity_index",
		            "size" => 10
		          },
		          "aggs" => {
		            "events" => {
		              "terms" => {
		                "field" => "event_name",
		                "size" => 300,
		        		"order" => { "_key" => "asc" }
		              },
		              "aggs" => {
	                  	"information" => {
	                  		"terms" => {
	                  			"field" => "information",
	                  			"size" => 300
	                  		},
	                  		"aggs" => {
	                  			"entities" => {
	                  				"terms" => {
					                    "field" => "entity_unique_name",
					                    "size" => 300
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
		  }
		}
	end

	## @param[Integer] download_session : the time of the download session
	## if nil is passed, it aggregates the last ten download session.
	## options[entities] => array of entity names
	## options[exchanges] => array of exchange names
	def self.view(options={})
		download_sessions = []
		puts "the options are: #{options}"
		response = gateway.client.search :index => index_name, :type => document_type, :body => body(options)
		aggs = Hashie::Mash.new(response).aggregations
		puts JSON.pretty_generate(aggs.to_hash)
		aggs.download_sessions.buckets.each do |bucket|
			d = new(epoch: bucket['key'].to_i, exchanges: [], human_readable_date: Time.strptime((bucket['key'].to_i/1000).to_i.to_s,"%s").strftime("%b %-d %Y, %-l:%M %P"))
			bucket["exchanges"].buckets.each do |exchange_bucket|
				exchange = Logs::Exchange.new
				exchange.name = exchange_bucket["key"]
				exchange_bucket.events.buckets.each do |event_bucket|
					event = Logs::Event.new
					event.name = event_bucket["key"]
					event_bucket.information.buckets.each do |information_bucket|
						information = Logs::Information.new
						information.name = information_bucket["key"]
						information_bucket.entities.buckets.each do |entity_bucket|
							entity = Logs::Entity.new
							entity.name = entity_bucket["key"]
							information.entities << entity
						end
						event.information << information
					end
					exchange.events << event
				end
				d.exchanges << exchange
			end
			download_sessions << d
		end
		download_sessions
	end

	

end