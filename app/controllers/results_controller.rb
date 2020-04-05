class ResultsController < ApplicationController

	## overriden from application controller.
	def set_meta_information
		# cannot be enforced.
	  	@title = DEFAULT_TITLE
	  	@meta_description = DEFAULT_META_DESCRIPTION
	  	@twitter_username = TWITTER_USERNAME
  	end

  	

  	## so now for the cloudinary prt.
  	def set_twitter_cards_information
=begin
	## twitter cards validator : 
	<meta name="twitter:card" content="summary" />
	<meta name="twitter:site" content="@flickr" />
	<meta name="twitter:title" content="Small Island Developing States Photo Submission" />
	<meta name="twitter:description" content="View the album on Flickr." />
	<meta name="twitter:image" content="https://farm6.staticflickr.com/5510/14338202952_93595258ff_z.jpg" />
=end
  	end
	
	def show
		@result = Result.es_find(params[:id],{})
	end

	def permitted_params
		params.permit(:entity_id)
	end

end