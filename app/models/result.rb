class Result
	include Mongoid::Document
	field :setup, type: String
	field :triggered_at, type: String
	embeds_many :impacts, :class_name => "Impact"
end