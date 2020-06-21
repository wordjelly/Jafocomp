class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  before_action :set_default_meta_information

  DEFAULT_TITLE = "Algorini - Stock Market Search Engine"

  DEFAULT_META_DESCRIPTION = "Algorini is a free search engine for stock market trading ideas. We crawl over 180 stocks and 5 exchanges. Search for any stock, to generate instant trading ideas."

  TWITTER_USERNAME = "tradejelly"

  ## what after ths.
  ## time to sort out titles as required.
  ## for individual shit.
  ## check the navbar.
  ## this should be on the resource itself
  ## for index actions -> the first resource.
  def set_default_meta_information
  	@title ||= DEFAULT_TITLE
  	@meta_description ||= DEFAULT_META_DESCRIPTION
    @social_title ||= ""
    @social_description ||= ""
    @social_url ||= ""
    @social_image_url ||= ""
  end

  


  ## so now how to set the layout.

end
