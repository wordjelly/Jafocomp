require 'elasticsearch/persistence/model'

class Logs::Information

	include Elasticsearch::Persistence::Model

	def self.index_properties
		{
			:name => {
				:type => 'keyword'
			},
			:entities => {
				:type => 'nested',
				:properties => Logs::Entity.index_properties
			}
		}
	end

	attribute :name, String
	attribute :entities, Array[Logs::Entity]

	

end