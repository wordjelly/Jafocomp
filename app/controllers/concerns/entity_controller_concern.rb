module Concerns::EntityControllerConcern
	
	extend ActiveSupport::Concern

	included do 


		skip_before_action :verify_authenticity_token, only: [:update,:force_create_index]

		before_action :find, :only => [:show,:update,:force_create_index]
		
		before_action :query, :only => [:show]
			
		## called from the backend to clear the frontend index.
		def force_create_index
			if @entity.authenticate?
				puts Stock.create_index! force: true 
			end
		end

		## this is set from individual actions (show, index) from different controllers.
		def set_individual_action_meta_information(args={})
			@title = args[:title]
			@meta_description = args[:description]
		end

		## submit to google search map also.
		def show
			puts params.to_s
		
			set_individual_action_meta_information({
				:title => @entity.page_title,
				:description => @entity.page_description
			})

			respond_to do |format|
				format.html do 
					render "/entities/show"
				end
				format.js do 
					render "/entities/show"
				end
				format.json do 
					render :json => @entity.as_json
				end
			end
		end


		def update_many
			get_resource_class.update_many
		end

		
		def index

			@entity = get_resource_class.new(permitted_params.fetch("entity",{}))
			
			@entities_by_exchange = @entity.do_index(permitted_params.fetch("entity",{}))

			set_individual_action_meta_information({
				:title => @entities_by_exchange[@entities_by_exchange.keys[0]][:stocks].first.page_title,
				:description =>@entities_by_exchange[@entities_by_exchange.keys[0]][:stocks].first.page_description
			})

			respond_to do |format|
				format.html do 
					render "/entities/index.html.erb"
				end

				format.js do 
					render "/entities/index.js.erb"
				end
			end
			
		end

		## make an exchanges controller.

		## will expect an id.
		def update
			#if Rails.env.production?
			
			@entity.save if @entity.authenticate?
			#else
			#	@entity.save
			#end
		end

		###############################################################
		##
		##
		## BEFORE ACTIONS
		##
		##
		###############################################################
		def find
			#puts "------------ came to find entity -------------- "
			@entity = get_resource_class.find_or_initialize(permitted_params.fetch("entity",{}).merge(:id => params[:id]))
			#puts "stock becomes:"
			#puts @entity.to_s
		end

		def query
			@entity.query(params.except(get_resource_name.to_sym))
		end

		def permitted_params
			k = params.permit(get_resource_class.permitted_params).to_h
			k
		end

		def get_resource_class
			controller_path.classify.constantize
		end

		def get_resource_name
			controller_name.singularize
		end

	end

end