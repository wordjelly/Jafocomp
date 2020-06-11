class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  before_action :set_meta_information

  DEFAULT_TITLE = "Algorini - Stock Market Search Engine"

  DEFAULT_META_DESCRIPTION = "What happens to US stocks in January? Get millions of simple trading tips, with Algorini Search."

  TWITTER_USERNAME = "tradejelly"

  ## time to sort out titles as required.
  ## for individual shit.
  ## check the navbar.
  def set_meta_information
  	@title ||= DEFAULT_TITLE
  	@meta_description ||= DEFAULT_META_DESCRIPTION
    @social_title ||= ""
    @social_description ||= ""
    @social_url ||= ""
    @social_image_url ||= ""
    puts "meta information has been set"
    puts "title is #{@title}, meta description is #{@meta_description}"
  end

  ## so now how to set the layout.

end
