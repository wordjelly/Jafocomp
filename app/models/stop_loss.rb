class StopLoss
	include Mongoid::Document
	embedded_in :statistic, :class_name => "Statistic"
	field :name, type: String
	field :icon_name, type: String
	field :total_profitable_trades, type: Integer
	field :total_loss_making_trades, type: Integer
	field :average_profit, type: Float
	field :average_loss, type: Float
	field :maximum_profit, type: Float
	field :maximum_loss, type: Float
	
end