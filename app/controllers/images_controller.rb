class ImagesController < ApplicationController
		
	## to require basic api authentication for any controller.
	include Auth::Concerns::DeviseConcern

	before_action :do_before_request

	respond_to :html, :json

	## so we can have certain information
	## like 
	## if no reports -> search bar
	## if reports -> categories -> inside categories -> edit
	## inside edit -> add_item -> barcode -> submit.
	## if history also pending -> then history ->
	## then finalize order.
	## that's it, there are only four steps.
	## after that there is nothing more to be done
	## reports -> requirements -> history -> finalize
	## game over
	## just pulsate these four.

	def new
		if permitted_params["image"].blank?
			@image = Image.new
		else
			@image = Image.new(permitted_params["image"])
		end
	end

	def show
		@image = Image.find(:id)
		@image.load_test_name
	end

	def create
		## what about dirty_tracking.
		@image = Image.new(permitted_params["image"])
		@image.save
		@errors = @image.errors
		respond_to do |format|
			format.html do 
				render "show"
			end
			format.json do 
				if @errors.full_messages.blank?
					render :json => {signature: @image.signed_request[:signature], errors: @errors.full_messages}
				else
					render :json => {signature: nil, errors: @errors.full_messages}
				end
			end
			format.text do 
				if @errors.full_messages.blank?
					render :plain => @image.signed_request[:signature]
				else
					render :plain => @errors.full_messages.to_s
				end
			end
		end
	end

	def update
		@image = Image.find(:id)
		@image.update_attributes(permitted_params[:image])
		respond_to do |format|
			format.html do 
				render "show"
			end
		end
	end

	def destroy
		@image = Image.find(params[:id])
		@image.delete
	end

	def index
		@images = Image.all
	end

	## we just need to detect it and upload it.
	## then we can make it searchable.
	## and we need the url.
	## so we modify image load concern method in requirement
	## to query for those names.
	## if there is an image_url
	## it will slow things down this idea.
	## so we do something like that
	## so that it loads only once.
	## image_urls => []
	## we put that like that.
	## so that's not too much of a problem.
	## what about laoding them

	def permitted_params
		puts "image permitted params are:"
		puts Image.permitted_params
		params.permit(Image.permitted_params)
	end

end