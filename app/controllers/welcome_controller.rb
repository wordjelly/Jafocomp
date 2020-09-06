class WelcomeController < ApplicationController

	def index
		Result.reload_front_page_trend
		unless $front_page_trend.blank?
			@result = $front_page_trend["_source"]
			@result["trends"] = @result["trends"][0..10]
		else
			@result = {"trends" => []}
		end
	end	

	## symptom index -> yes(because we have to search on symptoms)
	## 
	## question, answer, disease id, symptom, weightage.
	## this is the only document to create
	## all the other things, are not important.

	def our_story
		render "our_story"
	end

	## so we have a tooltip request.
	## for things that are to be shown as the information.
	## we send the match_query and show the first hit, as the result.
	def search
		#sleep(10)
		puts "params are:"
		puts params.to_s
		puts "permitted params are:"
		puts permitted_params
		context = permitted_params[:context]
		## this is the whole text.
		query = permitted_params[:query]
		information = permitted_params[:information]
		## suggest query is the last word of the query.
		## so it is possible, that we want the whole query also to be sent.
		suggest_query = permitted_params[:suggest_query]
		last_successfull_query = permitted_params[:last_successfull_query]
		results = nil

		direction = permitted_params[:direction]

		if information 
			results = Result.information({:information => information})
		else
			# so the prefix is either the suggest_query, or the whole_Query.
			results = Result.debug_suggest_r({:prefix => (suggest_query || query), :whole_query => query, :context => context, :last_successfull_query => last_successfull_query, :basic_query => params[:basic_query], :direction => direction})
		end

		respond_to do |format|
			format.json do 
				#puts "came to render json"
				render :json => {results: results, status: 200}
			end
		end	
	end

	def download_sessions
		download_sessions = Logs::DownloadSession.view({"exchanges" => params[:exchanges], "entities" => params[:entities]})
		respond_to do |format|
			format.json do 
				render :json => {download_sessions: download_sessions, status: 200}
			end
		end	
	end

	## shows all the logs for an individual poller session.
	## so this is possible.
	def poller_session
		## date filter.

		args = {}

		if params[:entity_unique_name]
			args[:entity_unique_name] = params[:entity_unique_name]
		end

		if params[:indice]
			args[:indice] = params[:indice]
		end

		if params[:poller_session_id]
			args[:poller_session_id] = params[:poller_session_id]
		end

		poller_session_rows = Logs::PollerSession.get(args)
		respond_to do |format|
			format.json do 
				render :json => {poller_session_rows: poller_session_rows, status: 200}
			end
		end
	end

	## filter by date, exchange, or entity.
	## right so that will have to be stored -> to pipe forward to get.
	def poller_sessions
		args = {}
			
		### ADD DATE RANGE QUERIES.
		### we can search for a particular date range.
		if params[:poller_sessions_upto]
			args[:poller_sessions_upto] = params[:poller_sessions_upto]
		end

		if params[:poller_sessions_from]
			args[:poller_sessions_from] = params[:poller_sessions_from]
		end

		if params[:entity_unique_name]
			args[:entity_unique_name] = params[:entity_unique_name]
		end

		if params[:indice]
			args[:indice] = params[:indice]
		end
		
		poller_session_rows = Logs::PollerSession.view(args)
		
		poller_session_rows.map{|c|
			c[:query_params] = args
		}

		respond_to do |format|
			format.json do 
				render :json => {poller_session_rows: poller_session_rows, status: 200}
			end
		end
	end


	def permitted_params
		## context will be a single string.
		params.permit(:query,{:context => []},:suggest_query,:information, :last_successfull_query, :basic_query, :exchange, :direction)
	end

end
