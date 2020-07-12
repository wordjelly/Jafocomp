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


	def permitted_params
		## context will be a single string.
		params.permit(:query,{:context => []},:suggest_query,:information, :last_successfull_query, :basic_query, :exchange, :direction)
	end

end
