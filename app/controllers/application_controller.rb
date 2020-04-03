class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  before_action :set_meta_information

  DEFAULT_TITLE = "Algorini - Share Market Search Engine"

  DEFAULT_META_DESCRIPTION = "Millions of Simple Answers like : What happens to US stocks on a Monday?"

  def set_meta_information
  	@title = DEFAULT_TITLE
  	@meta_description = DEFAULT_META_DESCRIPTION
  end

  ## so now how to set the layout.

end
