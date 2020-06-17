module Concerns::Stock::EntityConcern

	extend ActiveSupport::Concern

	included do 

		include Elasticsearch::Persistence::Model
		include Concerns::EsBulkIndexConcern
		include Concerns::Stock::IndividualConcern
		include Concerns::Stock::CombinationConcern
		include Concerns::Stock::CombinationQueryConcern 
		include Concerns::Stock::ExchangeConcern
		include Concerns::BackgroundJobConcern
		include ActiveModel::Validations
		include ActiveModel::Callbacks

		INFORMATION_TYPE_ENTITY = "entity"
		SINGLE = 0
		COMBINATION = 1
		NO = -1
		YES = 1

		index_name "frontend"
		document_type "doc"
		RISE = "rise"
		FALL = "fall"
		TREND_DIRECTIONS = ["rise","fall"]

		attribute :stock_is_exchange, Integer, mapping: {type: 'integer'}, default: NO

		attribute :stock_is_indicator, Integer, mapping: {type: 'integer'}, default: NO

		attribute :abbreviation, String, mapping: {type: 'keyword'}

		attribute :stock_name, String, mapping: {type: 'keyword'}

		attribute :stock_description, Integer, mapping: {type: 'keyword'}

		attribute :stock_link, String, mapping: {type: 'keyword'}

		attribute :stock_top_results, Array[Hash], mapping: {type: 'nested'}

		attribute :positive_results, Array[Hash], mapping: {type: 'nested'}

		attribute :negative_results, Array[Hash], mapping: {type: 'nested'}

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



		## why indicator combinations were not generated ?
		## for that we needed the stocks
		## 
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


		attr_accessor :trigger_update
		attr_accessor :stock_id
		attr_accessor :indicator_id
		attr_accessor :exchange_id
		attr_accessor :show_components
		attr_accessor :combine_with
	

		## should be used for pagination and other purposes.
		## size can be permitted.
		attr_accessor :from
		attr_accessor :size
		attr_accessor :total_pagination_blocks
		
		attr_accessor :trend_direction
				
		## because this has to be stored in the query_concern.
		attribute :total_results, Integer, mapping: {type: 'integer'}
		attribute :div_id, String,  mapping: {type: 'keyword'}
		## used in stocks_controller -> to show only the exchanges in the index action.
		attr_accessor :only_exchanges

		before_save do |document|
			document.set_abbreviation
		end

		## currently overriden only in Indicator class
		def set_abbreviation

		end


		after_find do |document|
			document.set_pagination_details
		end

		## so we will have to run the callbacks as after_find.
		def set_pagination_details
			self.from ||= 0
			self.size ||= 10
			self.total_pagination_blocks = 10
		end
		############################################################
		##
		##
		## CALLBACKS
		##
		##
		#############################################################
		after_save do |document|
			##puts "--------- CAME TO AFTER SAVE --------------- "
			schedule_background_update
		end

		def schedule_background_update
			ScheduleJob.perform_later([self.id.to_s,self.class.name.to_s,"update_it"]) unless self.trigger_update.blank?
		end

		def args_for_top_results_query
			{:query => "", :direction => nil, :impacted_entity_id => self.id.to_s}
		end

		def args_for_positive_results_query
			{:query => "", :direction => RISE, :impacted_entity_id => self.id.to_s}
		end

		def args_for_negative_results_query
			{:query => "", :direction => FALL, :impacted_entity_id => self.id.to_s}
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
			set_positive_results(args_for_positive_results_query)
			set_negative_results(args_for_negative_results_query)
			## that's it basically
			## now we mod those cards for the information query.
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
			##puts "came to update components."
			if is_index?
				##puts "is index is true."
				get_components.map{|hit|
					self.components << hit._source.information_name.strip unless self.components.include? hit._source.information_name.strip
				}
			else
				##puts "it is not an index #{self.stock_name}"
			end
		end

		## this here is the problem.
		def get_components
			##puts "came to get components"
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
			
			##puts query.to_s

			response = Hashie::Mash.new self.class.gateway.client.search :body => {:size => 100, :query => query}, :index => "correlations", :type => "result"
			
			##puts "Response is:"
			##puts response.to_s

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
			##puts "finished set name description"
		end	

		def get_icon
			if self.stock_is_indicator == YES
				"timeline"
			else
				"storage"
			end
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

			##puts JSON.pretty_generate(info.to_h)

			info

		end

		## @return[Hash] stocks_by_exchange
		## key -> exchange_name
		## value -> hash(:stocks => [Array of Stock Objects], :next_from => Integer)
		## @called_from : stocks_controller#index, and indicators_controller#index.
		def do_index(args={})

			#puts self.attributes.to_s
			## so if want to load more we can do that.
			stock_filters = 
			[
				{
					term: {
						stock_result_type: SINGLE
					}
				},
				{
					term: {
						stock_is_indicator: self.stock_is_indicator
					}
				}
			]

			stock_filters << {
				term: {
					stock_exchange: self.stock_exchange
				}
			} unless self.stock_exchange.blank?

			stock_filters << {
				term: {
					stock_is_exchange: self.stock_is_exchange
				}
			} if (self.stock_is_exchange == YES)


			puts "stock filters query is:"
			puts JSON.pretty_generate(stock_filters)

			search_request = self.class.search({
				size: 0,
				query: {
					bool: {
						must: stock_filters
					}
				},
				aggs: {
					exchange_agg: {
						terms: {
							field: "stock_exchange",
							size: 10
						},
						aggs: {
							stocks_agg: {
								top_hits: {
									size: 1,
									from: (self.from || 0)
								}
							}
						}
					}
				}
			})

			## so its not going to like this
			## and we have to deal with 
			stocks_by_exchange = {}
			
			#puts JSON.pretty_generate(search_request.response.to_h)

			search_request.response.aggregations.exchange_agg.buckets.each do |exchange_agg_bucket|

				exchange_name = exchange_agg_bucket["key"]
				stocks_by_exchange[exchange_name] ||= {:stocks => [], :next_from => (exchange_agg_bucket.stocks_agg.hits.hits.size + (self.from.to_i || 0) ) }
				exchange_agg_bucket.stocks_agg.hits.hits.each do |hit|
					stock = self.class.new(hit["_source"])
					stock.id = hit["_id"]
					stock.run_callbacks(:find)
					stocks_by_exchange[exchange_name][:stocks] << stock
				end
			end

			
			stocks_by_exchange
			
		end

		########################################################
		##
		##
		## used to build the sitemap
		## called_from Concerns::Stock::ExchangeConcern
		##
		##
		########################################################

		def entity_combinations
			## okay so how does this work exactly.

		end

		def indicator_combinations

		end

		def self.permitted_params
			[
				:id,
				:stock_id,
				:indicator_id,
				{
					:entity => 
					[
						:trigger_update,
						:from,
						:size,
						:stock_is_exchange,
						:stock_exchange,
						:stock_is_indicator,
						:trend_direction,
						:div_id,
						:show_components,
						:combine_with
					]
				}
			]
		end

		
	end

	module ClassMethods
		def find_or_initialize(args={})
			#puts "Came to find or initialize with args: #{args}"
			e = nil
			cls = args.delete(:class_name) || "Stock"
			cls = cls.constantize
			return cls.new(args) if ((args[:id].blank?))
			begin
				#puts index_name
				#puts document_type

				query = {
					bool: {
						should: [
							{
								ids: {
									values: [args[:id]]
								}
							},
							{
								term: {
									stock_name: args[:id]
								}
							}
						]
					}
				}

				#puts "query is:"
				#puts query.to_s
				## no idea why the fuck this is not working.

				search_response =  cls.gateway.client.search :body => {query: query}, index: index_name, :type => document_type

				#puts search_response.to_s
				
				hit = search_response["hits"]["hits"].first

				#puts "hit is:"
				#puts hit.to_s

				#hit = cls.gateway.client.get :id => args[:id], :index => Stock.index_name, :type => Stock.document_type
				raise Elasticsearch::Transport::Transport::Error if hit.blank?

				e = cls.new(hit["_source"])
				
				
				args.keys.each do |k|
					
					e.send("#{k}=",args[k])
					
				end
				e.id = hit["_id"]
				e.run_callbacks(:find)
				#puts "e div id before: #{e.div_id}"
				#puts "args--> #{args}"
				#ds = args.deep_symbolize_keys
				#puts "ds is #{ds}"
				#e.attributes.merge!(ds)
				#puts "attributes div id after merging:"
				#puts e.div_id
			rescue Elasticsearch::Transport::Transport::Error
				##puts "rescuing."
				#puts "args setting :#{args}"
				e = cls.new(args)
				##puts "args are :#{args}"
				e.set_name_description_link
				#puts "---------- came past that ---------------- "
			end
			#puts "trigger udpate is--------------: #{e.trigger_update}"
			#puts e.trigger_update.to_s
	 		e
		end
	end

end