module Concerns::Stock::EntityConcern

	extend ActiveSupport::Concern


	included do 

		INFORMATION_TYPE_ENTITY = "entity"
		SINGLE = 0
		COMBINATION = 1
		NO = -1
		YES = 1

		attribute :stock_is_exchange, Integer, mapping: {type: 'integer'}, default: NO

		attribute :stock_is_indicator, Integer, mapping: {type: 'integer'}, default: NO

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


		attribute :components, Array, mapping: {type: 'keyword'}

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
		attr_accessor :from
		## used in stocks_controller -> to show only the exchanges in the index action.
		attr_accessor :only_exchanges



		#############################################################
		##
		##
		## CALLBACKS
		##
		##
		#############################################################
		after_save do |document|
			#puts "--------- CAME TO AFTER SAVE --------------- "
			schedule_background_update
		end

		def schedule_background_update
			ScheduleJob.perform_later([self.id.to_s,self.class.name.to_s,"update_it"]) unless self.trigger_update.blank?
		end

		def args_for_top_results_query
			{:query => "", :direction => nil, :impacted_entity_id => self.id.to_s}
		end
		
		#############################################################
		##
		##
		## expected to be executed from a background job.
		##
		##
		#############################################################
		def update_it
			set_top_results(args_for_top_results_query)
			update_combinations
			update_components
			self.trigger_update = false
			self.stock_is_indicator = YES if self.class.name == "Indicator"
			self.save
		end

		## so this is done
		## next will be the combination.
		## best would be to have a combination object.
		## have a combinations controller.
		## 
		def update_components
			#puts "came to update components."
			if is_index?
				#puts "is index is true."
				get_components.map{|hit|
					self.components << hit._source.information_name.strip unless self.components.include? hit._source.information_name.strip
				}
			else
				#puts "it is not an index #{self.stock_name}"
			end
		end

		## this here is the problem.
		def get_components
			#puts "came to get components"
			query = {
				bool: {
					must: [
						{
							term: {
								information_type: Stock::INFORMATION_TYPE
							}
						},
						{
							term: {
								information_exchange_name: self.stock_exchange
							}
						}
					],
					must_not: [
						{
							exists: {
								field: "information_is_exchange"
							}
						}
					]
				}
			}	
			
			#puts query.to_s

			response = Hashie::Mash.new self.class.gateway.client.search :body => {:size => 100, :query => query}, :index => "correlations", :type => "result"
			
			#puts "Response is:"
			#puts response.to_s

			response.hits.hits
		end

		def is_index?
			self.stock_is_exchange == YES
		end

		def set_name_description_link
			if info = get_information
				self.stock_name = info._source.information_name.strip
				self.stock_description = info._source.information_description
				self.stock_link = info._source.information_link.strip unless info._source.information_link.blank?
				self.stock_exchange = info._source.information_exchange_name.strip
				self.stock_information_type = info._source.information_type.strip
				unless info._source.information_is_exchange.blank?
					self.stock_is_exchange = YES
				end
			end
			#puts "finished set name description"
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

			response = Hashie::Mash.new self.class.gateway.client.search :body => {:size => 1, :query => query}, :index => "correlations", :type => "result"
			
			info = nil

			if response.hits.hits.size > 0
				info = response.hits.hits.first
			end

			#puts JSON.pretty_generate(info.to_h)

			info

		end

	end

end