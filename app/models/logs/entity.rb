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
						exists: {
							field: "ohlcv_type"
						}
					},
					{
						term: {
							indice: args[:exchange_name]
						}
					}
				]
			}
		}
	end

	def self.entities_aggregation(args)
		{
	    	entities: {
	      		terms: {
	        		field: "symbol",
	        		size: 10
	      		},
		      	aggs: {
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
			                		_source: ["es_linked_list.data_point.close","es_linked_list.data_point.open","es_linked_list.data_point.low","es_linked_list.data_point.high","es_linked_list.data_point.volume","es_linked_list.data_point.day_of_month","es_linked_list.data_point.month_of_year","es_linked_list.data_point.year"
			                		]
			              		}
			            	}
			      		}
		        	}
		      	}
	    	}
		}
	end

	## returns an array of entities, with symbol and datapoints.
	def self.ticks(args={})
		
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
			entity = {"symbol" => entity_bucket["key"], "datapoints" => []}
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