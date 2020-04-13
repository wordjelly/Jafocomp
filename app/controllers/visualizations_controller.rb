class VisualizationsController < ApplicationController

	## overriden from application controller.
	def set_meta_information
	  	@title = DEFAULT_TITLE
	  	@meta_description = DEFAULT_META_DESCRIPTION
	  	@twitter_username = TWITTER_USERNAME
  	end

  	
  	def show
  		
  	end	

end