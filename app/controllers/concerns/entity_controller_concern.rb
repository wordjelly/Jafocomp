module Concerns::EntityControllerConcern
	
	extend ActiveSupport::Concern

	included do 

		before_action :find, :only => [:show,:update]
		before_action :query, :only => [:show]
		

		## submit to google search map also.
		def show
			puts params.to_s
			#puts @entity.to_s
			#puts JSON.pretty_generate(@entity.deep_attributes(false,false))
			puts "-------- entity div id ----------"
			puts @entity.div_id
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

		## so from the stocks controller we can handle this.
		## now the index action has to be spiced up to collate by entity.
		## how many entities to take per exchange
		## that has to be done in this aggregation.
		def index
			
			@entity = get_resource_class.new(permitted_params.fetch("entity",{}))
			
			@entities_by_exchange = @entity.do_index(permitted_params.fetch("entity",{}))

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
			@entity.save
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