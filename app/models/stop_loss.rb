class StopLoss
	include Mongoid::Document
	embedded_in :statistic, :class_name => "Statistic"
	field :name, type: String
	field :icon_name, type: String
end