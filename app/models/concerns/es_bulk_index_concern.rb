module Concerns::EsBulkIndexConcern
  extend ActiveSupport::Concern

  included do
  	cattr_accessor :bulk_items
  	cattr_accessor :total_items_bulked
  	## in case some multi search items were there.
  	cattr_accessor :search_results

  	self.bulk_items = []
  	self.total_items_bulked = 0

  	def deep_attributes(filter_permitted_params=false,include_blank_attributes=true)
			
		attributes = {}
			

		## why only the permitted params.
		## top level attributes
		permitted_params_list = []
		
		## if the second element is a hash, with the name of the class.
		### then take that
		## otherwise, take the top level itself.
		## today i want to finish
		## it does not blank the null elements
		## why not bypass this, as it can wipe a lot of other stuff as well
		## we can use scripted upsert ?
		## 

		if self.class.permitted_params[1].is_a? Hash
			
			if self.class.name.to_s =~ /#{self.class.permitted_params[1].keys[0]}/i
				permitted_params_list = self.class.permitted_params[1].values

			end
		else
			permitted_params_list = self.class.permitted_params
		end

		permitted_params_list.flatten!

		permitted_params_list.map!{|c|
			if c.is_a? Hash
			#	puts "got hash."
				c = c.keys[0]
			#	puts "c becomes: #{c}"
			else
				#puts "no hash."
			end 
			c
		}

		#puts "permitted params list is:"
		
		#puts permitted_params_list.to_s
		
		#exit(1)

		
		self.class.attribute_set.each do |virtus_attribute|
			#puts "doing attribute: #{virtus_attribute.name}"
			if filter_permitted_params == true
				next unless permitted_params_list.include? virtus_attribute.name.to_s.to_sym 
			end
			if virtus_attribute.primitive.to_s == "Array"
				#puts "is an array"
				attributes[virtus_attribute.name.to_s] = []
				if virtus_attribute.respond_to? "member_type"
					class_name = virtus_attribute.member_type.primitive.to_s
					
					self.send(virtus_attribute.name).each do |obj|
						
						unless class_name == "BasicObject"

							if obj.class.name == "Hash"
								attributes[virtus_attribute.name.to_s] << obj
							elsif obj.class.name == "Array"
								attributes[virtus_attribute.name.to_s] << obj
							else
								attributes[virtus_attribute.name.to_s] << obj.deep_attributes(filter_permitted_params,include_blank_attributes)
							end

						else
							## so its a hash.
							attributes[virtus_attribute.name.to_s] << obj.to_s

						end
					end
					
				end
			else
				attributes[virtus_attribute.name.to_s] = self.send(virtus_attribute.name)
				
			end
		end
		attributes["id"] = self.id.to_s
		if include_blank_attributes.blank?
			attributes.delete_if{|key,value|
				value.blank?
			}
		end 
		attributes
	end

	##override in implementing model.
	def self.bulk_size
	  5000
	end

	def self.reset_bulk_items
		self.bulk_items = []
	end

	## the total number of items that have been sent to es
	## through the bulk mechanism.
	def self.add_total
		self.total_items_bulked += self.bulk_items.size
	end

	def self.do_bulk
		##puts "called do bulk"
		##puts "bulk items are:"
		##puts bulk_items.to_s
		add_total
	  	##puts "building bulk items"
	  	if bulk_items.blank?
	  		##puts "nothing to bulk"
	  		return
	  	end

	  	## so we have to gather the multisearch requests.
	  	search_requests = []
	  	bulk_items.delete_if { |e|
	  		if e.is_a? Hash
		  		unless e[:search].blank?
					search_requests << e
					true	  			
		  		end
	  		end
	  	}
	  	
	  	bulk_request = bulk_items.map{|c|

	  		unless c.is_a? Hash
				c = {
	  					index:  { _index: c.class.index_name, _id: c.id, _type: c.class.document_type, data: c.as_json }
	  				}	  			
	  		end

	  		c
	  	}

	  	##puts "making bulk call"
	  	##puts JSON.pretty_generate(bulk_request)
	  	resp = gateway.client.bulk body: bulk_request unless bulk_items.blank?
	  	#we need to return the response of the bulk call.
	  	#problem is that this is not reliable.
	  	#
	  	##puts "search requests are=====================>:"
	  	##puts search_requests.to_s
		unless search_requests.blank?

			multi_response = gateway.client.msearch body: search_requests 
			##puts "the search results are:"
			##puts multi_response.to_s
			self.search_results = multi_response["responses"]
		end
		if total_items_bulked.size > 0
			#puts "completed bulk of #{bulk_size} items."
			#puts "total bulked : #{total_items_bulked}"
			#puts "#{Time.now.to_i}"
		end
		reset_bulk_items
	end

	def self.add_bulk_item(item)
		##puts "adding bulk item at: #{Time.now.to_i}"
		##puts item.to_s
	  	if total_items = self.bulk_items.size
	  		bulk_items << item if total_items < self.bulk_size
	  		do_bulk if total_items >= self.bulk_size
	  	end
	end

	## call this method at the end somewhere in the place where you are adding bulk items.
	def self.flush_bulk
		do_bulk
	end

  end

end