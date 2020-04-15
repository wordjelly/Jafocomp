class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  after_action :set_meta_information

  DEFAULT_TITLE = "Algorini - Share Market Search Engine"

  DEFAULT_META_DESCRIPTION = "Millions of Simple Answers like : What happens to US stocks on a Monday?"

  TWITTER_USERNAME = "tradejelly"

  def set_meta_information
  	@title = DEFAULT_TITLE
  	@meta_description = DEFAULT_META_DESCRIPTION
    @social_title = ""
    @social_description = ""
    @social_url = ""
    @social_image_url = ""
  end

  ## so now how to set the layout.

end
