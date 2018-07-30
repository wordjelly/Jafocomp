class Impact
	include Mongoid::Document
	field :entity_name, type: String
	field :entity_unique_id, type: String
	field :entity_index_name, type: String
	field :effect, type: String
	field :indicator_name, type: String
	field :indicator_id, type: String
	field :subindicator_name, type: String
	field :subindicator_id, type: String
	embeds_many :statistics, :class_name => "Statistic"
end