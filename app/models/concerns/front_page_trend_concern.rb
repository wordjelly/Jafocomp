module Concerns::FrontPageTrendConcern

	extend ActiveSupport::Concern

  	included do

  	end

  	module ClassMethods  

  		def reload_front_page_trend
			#puts "came to reload front page trend."
			$front_page_trend_loaded_at ||= Time.now - 6.hours
			if Time.now.to_i > $front_page_trend_loaded_at.to_i
				#puts "current time is greater #{(Time.now.to_i - $front_page_trend_loaded_at.to_i)}"
				if ((Time.now.to_i - $front_page_trend_loaded_at.to_i) > 3600*4)
					#puts "setting front page trend."
					$front_page_trend = front_page_trend
					#puts "front page trend is;"
					#puts $front_page_trend
					$front_page_trend_loaded_at = Time.now
				end
			end
		end
		## maybe i can get just the first 5 or something.
		## so any number of trends.
		## we can store.
		## but it will become an ajax call whichever way you go for it.
		def front_page_trend
			gateway.client.get index: "correlations", id: "R-front_page_trend"
		end

  	end


end