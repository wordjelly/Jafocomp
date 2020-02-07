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

end