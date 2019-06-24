require 'elasticsearch/persistence/model'
class Sector

	include Elasticsearch::Persistence::Model

	attribute :information_name, String

	attribute :related_queries, Array

	attribute :counter, Integer

	SECTOR_INFORMATION_TYPE = "sector"

	def self.load_sectors
		sector_counter_to_name = {}
		sector_name_to_counter = {}
		body = {
			size: 100,
			query: {
				bool: {
					must: [
						term: {
							information_type: SECTOR_INFORMATION_TYPE
						}
					]
				}
			}
		}
		response = gateway.client.search index: "correlations", body: body
		
		response["hits"]["hits"].map{|hit| 

			sector = Sector.new(hit["_source"])
			sector_counter_to_name[sector.counter.to_s] = sector
			sector_name_to_counter[sector.information_name] = sector.counter.to_s
		}	

		{
			sector_counter_to_name: sector_counter_to_name,
			sector_name_to_counter: sector_name_to_counter
		}
	end
end