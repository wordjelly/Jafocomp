class StopLoss
	include Mongoid::Document
	include Concerns::StatsConcern
	embedded_in :result, :class_name => "Result"
end