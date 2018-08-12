class Statistic
	include Mongoid::Document
	field :time_frame_name, type: String
	field :time_frame_unit, type: String
	field :time_frame, type: Integer
	field :total_up, type: Integer
	field :total_down, type: Integer
	field :average_profit, type: Float
	field :average_loss, type: Float
	field :maximum_profit, type: Float
	field :maximum_loss, type: Float
	field :see_more_icon_color, type: String
	embeds_many :stop_losses, :class_name => "StopLoss"
end