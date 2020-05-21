class StocksController < ApplicationController


	before_action :find, :only => [:show,:update]
	before_action :query, :only => [:show]

	## so lets see if this shit works or not.
	## so lets test if it shows the first stock.
	def show
		puts "------------------ STOCK IN SHOW IS ---------------- "
		puts @stock.to_s
		respond_to do |format|
			format.html do 
				render :show
			end
			format.json do 
				render :json => @stock.as_json
			end
		end
	end

	## so from the stocks controller we can handle this.
	## now the index action has to be spiced up to collate by entity.
	## how many entities to take per exchange
	## that has to be done in this aggregation.
	def index

		@stock = Stock.new(permitted_params.fetch("stock",{}))

		## so if want to load more we can do that.
		stock_filters = 
		[
			{
				term: {
					stock_result_type: Stock::SINGLE
				}
			},
			{
				term: {
					stock_is_indicator: Concerns::Stock::EntityConcern::NO
				}
			}
		]

		stock_filters << {
			term: {
				stock_exchange_name: @stock.stock_exchange
			}
		} unless @stock.stock_exchange.blank?

		stock_filters << {
			term: {
				stock_is_exchange: @stock.stock_is_exchange
			}
		} if (@stock.stock_is_exchange == Concerns::Stock::EntityConcern::YES)


		puts "stock filters query is:"
		puts JSON.pretty_generate(stock_filters)

		search_request = Stock.search({
			size: 0,
			query: {
				bool: {
					must: stock_filters
				}
			},
			aggs: {
				exchange_agg: {
					terms: {
						field: "stock_exchange",
						size: 10
					},
					aggs: {
						stocks_agg: {
							top_hits: {
								size: 1,
								from: (@stock.from || 0)
							}
						}
					}
				}
			}
		})

		## so its not going to like this
		## and we have to deal with 
		@stocks_by_exchange = {}
		
				

		search_request.response.aggregations.exchange_agg.buckets.each do |exchange_agg_bucket|

			exchange_name = exchange_agg_bucket["key"]
			@stocks_by_exchange[exchange_name] ||= {:stocks => [], :next_from => (exchange_agg_bucket.stocks_agg.hits.hits.size + (@stock.from || 0) ) }
			exchange_agg_bucket.stocks_agg.hits.hits.each do |hit|
				stock = Stock.new(hit["_source"])
				stock.id = hit["_id"]
				## this is just wrong.
				@stocks_by_exchange[exchange_name][:stocks] << stock
			end
		end

		respond_to do |format|
			format.html do 
				render "/stocks/index.html.erb"
			end

			format.js do 
				render "/stocks/index.js.erb"
			end
		end
		
	end

	## make an exchanges controller.

	## will expect an id.
	def update
		@stock.save
	end

	###############################################################
	##
	##
	## BEFORE ACTIONS
	##
	##
	###############################################################
	def find
		puts "------------ came to find stock -------------- "
		@stock = Stock.find_or_initialize(permitted_params.fetch("stock",{}).merge(:id => params[:id]))
		puts "stock becomes:"
		puts @stock.to_s
	end

	def query
		@stock.query(params.except(:stock))
	end

	def permitted_params
		#puts "params are: #{params}"
		k = params.permit(Stock.permitted_params).to_h
		#puts k.to_s
		k
	end

end