module Concerns::Stock::EntityConcern

	extend ActiveSupport::Concern


	included do 

		INFORMATION_TYPE_ENTITY = "entity"
		SINGLE = 0
		COMBINATION = 1

		attribute :stock_name, String, mapping: {type: 'keyword'}

		attribute :stock_description, Integer, mapping: {type: 'keyword'}

		attribute :stock_link, String, mapping: {type: 'keyword'}

		attribute :stock_top_results, Array[Hash], mapping: {type: 'nested'}

		attribute :stock_exchange, String, mapping: {type: 'keyword'}

		## indicator, entity.
		attribute :stock_information_type, String, mapping: {type: 'keyword'}

		## stock show.

		attribute :stock_result_type, Integer, default: SINGLE, mapping: {type: 'integer'}

		attribute :stock_impacted, String, mapping: {type: 'keyword'}

		attribute :stock_impacted_id, String, mapping: {type: 'keyword'}

		attribute :stock_impacted_description, String, mapping: {type: 'keyword'}

		attribute :stock_impacted_link, String, mapping: {type: 'keyword'}

		attribute :stock_primary, String, mapping: {type: 'keyword'}

		attribute :stock_primary_id, String, mapping: {type: 'keyword'}

		attribute :stock_primary_description, String, mapping: {type: 'keyword'}

		attribute :stock_primary_link, String, mapping: {type: 'keyword'}
		## and what about for the indicators?
		## the exchanges, are the exchanges of the two entities in the complex.
		attribute :stock_primary_exchange, String, mapping: {type: 'keyword'}

		attribute :stock_impacted_exchange, String, mapping: {type: 'keyword'}

		## like i want to look at an indicator.
		## then we want its combinations
		attribute :indicator_primary_id, String, mapping: {type: 'keyword'}

		attribute :indicator_primary_name, String, mapping: {type: 'keyword'}

		## these have to be cross updated.
		## do we load the entirety of it ?
		## or just some shits.
		## can we load or what to do ?
		## and how to present them
		## it will have to work with lazy load.
		attribute :combinations, Array[Hash], mapping: {
			type: 'nested',
			properties: {
				exchange_name: {
					type: 'keyword'
				},
				entities: {
					type: 'nested',
					properties: {
						primary_entity_name: {
							type: 'keyword'
						},
						primary_entity_id: {
							type: 'keyword'
						},
						primary_entity_exchange: {
							type: 'keyword'
						},
						top_n_hit_ids: {
							type: 'keyword'
						},
						combination_id: {
							type: 'keyword'
						},
						impacted_entity_id: {
							type: 'keyword'
						}
					}
				}
			} 
		}

		index_name "frontend"
		document_type "doc"

		attr_accessor :trigger_update
		attr_accessor :stock_id
		attr_accessor :indicator_id
		attr_accessor :exchange_id
		attr_accessor :skip



		#############################################################
		##
		##
		## CALLBACKS
		##
		##
		#############################################################
		after_save do |document|
			puts "--------- CAME TO AFTER SAVE --------------- "
			schedule_background_update
		end

		def schedule_background_update
			ScheduleJob.perform_later([self.id.to_s,self.class.name.to_s,"update_it"]) unless self.trigger_update.blank?
		end
		
		#############################################################
		##
		##
		## expected to be executed from a background job.
		##
		##
		#############################################################
		def update_it
			#puts "came to update in background job."
			update_top_results
			#puts "going to update combinations ----------------->"
			update_combinations
			self.trigger_update = false
			self.save
		end

		def set_name_description_link
			if info = get_information
				self.stock_name = info._source.information_name
				self.stock_description = info._source.information_description
				self.stock_link = info._source.information_link
				self.stock_exchange = info._source.information_exchange
				self.stock_information_type = info._source.information_type
			end
			puts "finished set name description"
		end	

		def get_information(information_type="entity")
			query = {
				bool: {
					must: [
						{
							term: {
								information_type: information_type
							}
						},
						{
							term: {
								information_id: self.id.to_s
							}
						}
					]
				}
			}	
			#puts query.to_s

			response = Hashie::Mash.new self.class.gateway.client.search :body => {:size => 1, :query => query}, :index => "correlations", :type => "result"
			
			puts "Response is:"
			puts response.to_s

			info = nil

			if response.hits.hits.size > 0
				info = response.hits.hits.first
			end

			info

		end

	end

end