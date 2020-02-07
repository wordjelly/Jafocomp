require 'elasticsearch/persistence/model'

class Logs::Exchange
	
	include Elasticsearch::Persistence::Model
	
	def self.index_properties
		{
			:name => {
				:type => 'keyword'
			},
			:summary => {
				:type => 'keyword'
			},
			:download_sessions => {
				:type => 'nested',
				:properties => Logs::DownloadSession.bare_properties
			},
			:events => {
				:type => 'nested',
				:properties => Logs::Event.index_properties
			}
		}
	end

	def self.bare_properties
		{
			:name => {
				:type => 'keyword'
			},
			:summary => {
				:type => 'keyword'
			},
			:events => {
				:type => 'nested',
				:properties => Logs::Event.index_properties
			}
		}
	end

	index_name "tradegenie_titan"
	document_type "doc"

	attribute :name, String, mapping: {type: 'keyword'}
	attribute :summary, String, mapping: {type: 'keyword'}
	attribute :download_sessions, Array[Logs::DownloadSession], mapping: {type: 'nested', properties: Logs::DownloadSession.index_properties }
	attribute :events, Array[Logs::Event], mapping: {type: 'nested', properties: Logs::Event.index_properties}

	

	

end
