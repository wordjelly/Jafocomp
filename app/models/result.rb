class Result
	include Mongoid::Document
	include Concerns::StatsConcern
	embeds_many :stop_losses, class_name => "StopLoss"
	field :suggestions, type: Array
end