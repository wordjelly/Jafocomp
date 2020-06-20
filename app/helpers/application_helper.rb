module ApplicationHelper
	def get_trend_direction(entity)
		entity.trend_direction == "rise" ? "Positive" : "Negative"
	end

	## @return[String]
	## the new pagination url, with from updated.
	## @args[Hash] args : a hash of incoming arguments.
	## required :
	## original_url : the original url of the request, can be got in the view by using controller.request.original_url
	## from : the new from, for the pagination.
	## if the two paramters are not there, will return nothing of any use.
	## currently called from /views/entities/paginate.html.erb
	def get_pagination_url(args={})
		return "/" if args[:original_url].blank?
		return args[:original_url] if args[:from].blank?
		Rails.logger.debug("came to get pagination url with args")
		Rails.logger.debug(args)
		if args[:original_url] =~ /from\=\d+/
			args[:original_url].gsub(/from\=\d+/) { |match|
				"from=#{args[:from]}"
			}
		else
			if args[:original_url] =~ /\?/
				args[:original_url] + "&from=#{args[:from]}"
			else
				args[:original_url] + "?from=#{args[:from]}" 
			end
		end	
	end

end
