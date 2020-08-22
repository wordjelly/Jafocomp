require 'elasticsearch/persistence/model'
class Sector

	include Elasticsearch::Persistence::Model

	attribute :information_name, String

	attribute :related_queries, Array

	attribute :counter, Integer

	SECTOR_INFORMATION_TYPE = "sector"
	ENTITY_INFORMATION_TYPE = "entity"

	def self.load_sectors
		sector_counter_to_name = {}
		sector_name_to_counter = {}
		body = {
			size: 300,
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
		begin
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
		rescue => e
			Rails.logger.error(e)
			{
				sector_counter_to_name: {},
				sector_name_to_counter: {}
			}
		end
	end

	## we want to get the information actually.
	## do we have any type or anything.
	def self.load_entities
		
		## so we have enxchanges
		
		entities_by_exchange = {}

		body = {
			size: 300,
			query: {
				bool: {
					must: [
						term: {
							information_type: ENTITY_INFORMATION_TYPE
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



	end

end