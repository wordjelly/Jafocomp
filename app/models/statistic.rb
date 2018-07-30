class Statistic
	include Mongoid::Document
	field :time_frame_name, type: String
	field :time_frame, type: Integer
	field :total_up, type: Integer
	field :total_down, type: Integer
	embeds_many :stop_losses, :class_name => "StopLoss"
end