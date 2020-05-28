module ApplicationHelper
	def get_trend_direction(entity)
		entity.trend_direction == "rise" ? "Positive" : "Negative"
	end
end
