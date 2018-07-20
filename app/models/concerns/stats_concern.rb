module Concerns::StatsConcern

	included do 

		### check if mongoid is already included.
		### otherwise include it.

		field :title, type: String
		field :percentage_of_profitable_trades, type: Float
		field :average_profit, type: Float
		field :biggest_gain, type: Float
		field :biggest_loss, type: Float

	end

end