require 'elasticsearch/persistence/model'

class Entity

	include Elasticsearch::Persistence::Model

	SINGLE = 0
	COMBINATION = 1

	attribute :display_name, String

	attribute :description, Integer

	attribute :top_results, Array[Hash]

	attribute :result_type, Integer, default: SINGLE

	## the exchanges, are the exchanges of the two entities in the complex.
	attribute :exchanges, Array

	index_name "tradegenie_titan"
	document_type "doc"

	## called when a single entity is to be shown.
	## loads all the combinations with this entity in them.
	## in each combination, top 5 hits are there, stored already.
	def get_details
		
	end	


	## if "more" is clicked on combination -> then it will show multiple results, basically return search_results, by doing a simple query.
	## here it will show the first card for each result on the front end.
	## and offer pagination support.

end