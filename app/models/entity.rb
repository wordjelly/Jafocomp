require 'elasticsearch/persistence/model'

class Entity

	include Elasticsearch::Persistence::Model

	INFORMATION_TYPE_ENTITY = "entity"
	SINGLE = 0
	COMBINATION = 1


	attribute :entity_display_name, String, mapping: {type: 'keyword'}

	attribute :entity_description, Integer, mapping: {type: 'integer'}

	attribute :entity_top_results, Array[Hash], mapping: {type: 'nested'}

	attribute :entity_result_type, Integer, default: SINGLE, mapping: {type: 'integer'}

	attribute :entity_impacted, String, mapping: {type: 'keyword'}

	attribute :entity_primary, String, mapping: {type: 'keyword'}
	## the exchanges, are the exchanges of the two entities in the complex.
	attribute :entity_exchanges, Array


	index_name "frontend"
	document_type "doc"

	## called when a single entity is to be shown.
	## loads all the combinations with this entity in them.
	## in each combination, top 5 hits are there, stored already.
	def self.get_combinations

	end


	## if "more" is clicked on combination -> then it will show multiple results, basically return search_results, by doing a simple query.
	## here it will show the first card for each result on the front end.
	## and offer pagination support.

	## @called_From : entities_controller => triggered by a post request on the entities_controller from the java program, making a simple rest api call.
	def trigger_rebuild
		ScheduleJob.perform_later([self.id.to_s,"Entity","rebuild_entities"])
	end

	#############################################################
	##
	##
	## expected to be executed from a background job.
	##
	##
	#############################################################
	def rebuild_entities
		## first search for top 5.
	end


	## because we want impacted entity.
	## for that query.
	## we need an entity id.
	## check the get information query.
	## and pull it out of that.
	## we need id, index, entity_name, description.
	## thsi 
	def get_all_other_entity_names
		query = {
			bool: {
				must: [
					{
						term: {
							information_type: INFORMATION_TYPE_ENTITY
						}
					}
				]
			}
		}
		response = Hashie::Mash.new Entity.gateway.client.search {
			:body => {
				"size" => 200,
				"query" => query
			},
			:index => "correlations",
			:type => "result"
		}

		response.hits.hits.each do |hit|
			## hit has the information name.
			## and entity id.
			## so given entity -> where we are impacted.
			## we have to do a nested query only
			## but with the feature for an impacted_entity_id.
		end

	end


end