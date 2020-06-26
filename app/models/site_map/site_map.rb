require 'elasticsearch/persistence/model'
require 'sitemap_generator'
require 'google/cloud/storage'

class SiteMap::SiteMap

	include Elasticsearch::Persistence::Model
	include Concerns::BackgroundJobConcern
	include Concerns::EsBulkIndexConcern

	attribute :exchange_name, String, mapping: {type: 'keyword'}
	attribute :exchange_id, String, mapping: {type: 'keyword'}
	attribute :entity_id, String, mapping: {type: 'keyword'}
	
	attr_accessor :exchange
	attr_accessor :entity
	## it adds crud on its own.
	## so we make a sitemaps controller and hook it into a background job
	## today mostly cloning -> and 
	## don't allow newer categories ??? what say, that prevents fuck ups.

	#CREDENTIALS_PATH = Rails.root.join("config","keys","google_cloud_storage_bhargav_r_raut@gmail.com_service_account_dark-edge-264914-3c2e40ad386e.json")

	#JSON.parse(ENV["GOOGLE_CLOUD_CREDENTIALS"])

	#

	after_save do |document|
		document.schedule_background_update
	end

	def schedule_background_update
		ScheduleJob.perform_later([self.id.to_s,self.class.name.to_s,"build_sitemap"])
	end

	def get_credentials_path
		if Rails.env.production?
			StringIO.new(ENV["GOOGLE_CLOUD_CREDENTIALS"])
		else
			Rails.root.join("config","keys","google_cloud_storage_bhargav_r_raut@gmail.com_service_account_dark-edge-264914-3c2e40ad386e.json")
		end
	end

	## lets see if this much works or not
	## then we go to the final endpoint.
	## will have to try it on heroku itself.

	def get_exchange
		self.exchange
	end

	## if i can solve saturation problems, it will be almost done
	## then just a little debugging, but we are in business.

	def build_exchange_sitemap
		set_exchange
		Rails.logger.debug("came to create sitemap, with self exchange :#{self.exchange.id.to_s}")
		all_other_stocks = get_exchange.get_all_other_stocks
		all_indicators = Indicator.get_indicators_from_frontend_index
		exchange_entities = get_exchange.entities
		puts "exchange entities are:"
		puts exchange_entities.to_s
		#exit(1)

		puts "------------------ all other stocks keys are ----------------- "
		puts all_other_stocks.keys.to_s

		# Your website's host name
		SitemapGenerator::Sitemap.default_host = "https://www.algorini.com"

		# so this is also wrong.
		# The remote host where your sitemaps will be hosted
		SitemapGenerator::Sitemap.sitemaps_host = "https://storage.googleapis.com/algorini"

		SitemapGenerator::Sitemap.create_index = true

		# The directory to write sitemaps to locally
		SitemapGenerator::Sitemap.public_path = 'tmp/'

		# Set this to a directory/path if you don't want to upload to the root of your `sitemaps_host`
		SitemapGenerator::Sitemap.sitemaps_path = 'sitemaps/'

		## useful for debugging.
		SitemapGenerator::Sitemap.compress = true

		unless Rails.env.production?
			adapter = SitemapGenerator::GoogleStorageAdapter.new(
			  project_id: ENV["GOOGLE_CLOUD_PROJECT"],
			  bucket: "algorini",
			  credentials: get_credentials_path
			)
		else
			adapter = SitemapGenerator::GoogleStorageAdapter.new(
			  project_id: ENV["GOOGLE_CLOUD_PROJECT"],
			  bucket: "algorini"
			)
		end

		SitemapGenerator::Sitemap.adapter = adapter

		# lets take a look at the sitemap.

		## so now let me focus on generating this shite.
		## add the stock pages, indicator pages and exchange pages.
		## and then test it.
		SitemapGenerator::Sitemap.create do
			
			exchange_entities.each do |exchange_entity|
				
				## entity page.
				add Rails.application.routes.url_helpers.stock_path(exchange_entity.stock_name), :changefreq => "daily", :priority => 0.9


				## trend directions.
				Concerns::Stock::EntityConcern::TREND_DIRECTIONS.each do |td|
					add Rails.application.routes.url_helpers.direction_entity_path(exchange_entity.stock_name,td), :changefreq => "daily", :priority => 0.9
				end
		
				## indicator combinations.
				all_indicators.each do |indicator| 
					
					puts "indicator name :#{indicator.stock_name}"
					#puts JSON.pretty_generate(indicator.attributes)
					
					add Rails.application.routes.url_helpers.combination_indicator_path(exchange_entity.stock_name,indicator.stock_name), :changefreq => "daily", :priority => 0.9
				end

				## other entity combinations.
				all_other_stocks.keys.each do |exchange_name|
					all_other_stocks[exchange_name].each do |impacted_stock|
						## combination path
						## entity path.
						add Rails.application.routes.url_helpers.combination_entity_path(impacted_stock.stock_name,exchange_entity.stock_name), :changefreq => "daily", :priority => 0.9
					end
				end
			end
		end

		## you want to update the index.
		SitemapGenerator::Sitemap.ping_search_engines('https://algorini.com/sitemap.xml.gz')

	end

	## called_from : build_entity_sitemap
	def add_entity_sitemap_to_sitemap_index(args={})
		puts "sitemap name:#{args[:sitemap_name]}"
		# Your website's host name
		SitemapGenerator::Sitemap.default_host = "https://www.algorini.com"

		# so this is also wrong.
		# The remote host where your sitemaps will be hosted
		SitemapGenerator::Sitemap.sitemaps_host = "https://storage.googleapis.com/algorini"

		SitemapGenerator::Sitemap.create_index = true

		# The directory to write sitemaps to locally
		SitemapGenerator::Sitemap.public_path = 'tmp/'

		# Set this to a directory/path if you don't want to upload to the root of your `sitemaps_host`
		SitemapGenerator::Sitemap.sitemaps_path = 'sitemaps/'

		## useful for debugging.
		SitemapGenerator::Sitemap.compress = false

		SitemapGenerator::Sitemap.namer = SitemapGenerator::SimpleNamer.new(:sitemap)

		puts "came to addd to index ---------------------------->"
		SitemapGenerator::Sitemap.create do
			args[:all_other_stocks].keys.each do |exchange|
				args[:all_other_stocks][exchange].each do |stock|
		  			add_to_index "/#{stock.sitemap_file_name}"
		  		end
		  	end
		  	## will also have to do for indicators.
		  	## and basic navigation pages here.
		end

	end

	def build_entity_sitemap

		set_entity

		Rails.logger.debug("came to create sitemap, with entity id :#{self.entity_id}")
		all_other_stocks = get_entity.get_all_other_stocks
		all_indicators = Indicator.get_indicators_from_frontend_index
		exchange_entities = [get_entity]
		#puts "exchange entities are:"
		#puts exchange_entities.to_s
		#exit(1)

		puts "------------------ all other stocks keys are ----------------- "
		puts all_other_stocks.keys.to_s

		# Your website's host name
		SitemapGenerator::Sitemap.default_host = "https://www.algorini.com"

		# so this is also wrong.
		# The remote host where your sitemaps will be hosted
		SitemapGenerator::Sitemap.sitemaps_host = "https://storage.googleapis.com/algorini"

		SitemapGenerator::Sitemap.create_index = false

		# The directory to write sitemaps to locally
		SitemapGenerator::Sitemap.public_path = 'tmp/'

		# Set this to a directory/path if you don't want to upload to the root of your `sitemaps_host`
		SitemapGenerator::Sitemap.sitemaps_path = 'sitemaps/'

		## useful for debugging.
		SitemapGenerator::Sitemap.compress = false

		sitemap_file_name = get_entity.stock_name.gsub(/\s/,"") + ".xml.gz"

		SitemapGenerator::Sitemap.namer = SitemapGenerator::SimpleNamer.new(get_entity.stock_name.gsub(/\s/,"").to_sym)

		## the namer has to be set.
		## and add to index is called seperately.

		adapter = nil

		unless Rails.env.production?
			adapter = SitemapGenerator::GoogleStorageAdapter.new(
			  project_id: ENV["GOOGLE_CLOUD_PROJECT"],
			  bucket: "algorini",
			  credentials: get_credentials_path
			)
		else
			adapter = SitemapGenerator::GoogleStorageAdapter.new(
			  project_id: ENV["GOOGLE_CLOUD_PROJECT"],
			  bucket: "algorini"
			)
		end

		SitemapGenerator::Sitemap.adapter = adapter

		# lets take a look at the sitemap.

		## so now let me focus on generating this shite.
		## add the stock pages, indicator pages and exchange pages.
		## and then test it.
		SitemapGenerator::Sitemap.create do
			
			exchange_entities.each do |exchange_entity|
				
				## entity page.
				add Rails.application.routes.url_helpers.stock_path(exchange_entity.stock_name), :changefreq => "daily", :priority => 0.9


				## trend directions.
				Concerns::Stock::EntityConcern::TREND_DIRECTIONS.each do |td|
					add Rails.application.routes.url_helpers.direction_entity_path(exchange_entity.stock_name,td), :changefreq => "daily", :priority => 0.9
				end
		
				## indicator combinations.
				all_indicators.each do |indicator| 
					
					puts "indicator name :#{indicator.stock_name}"
					#puts JSON.pretty_generate(indicator.attributes)
					
					add Rails.application.routes.url_helpers.combination_indicator_path(exchange_entity.stock_name,indicator.stock_name), :changefreq => "daily", :priority => 0.9
				end

				## other entity combinations.
				all_other_stocks.keys.each do |exchange_name|
					all_other_stocks[exchange_name].each do |impacted_stock|
						## combination path
						## entity path.
						add Rails.application.routes.url_helpers.combination_entity_path(impacted_stock.stock_name,exchange_entity.stock_name), :changefreq => "daily", :priority => 0.9
					end
				end
			end
		end

		add_entity_sitemap_to_sitemap_index({:sitemap_name => sitemap_file_name})

		## you want to update the index.
		##SitemapGenerator::Sitemap.ping_search_engines('https://algorini.com/sitemap.xml.gz')
		
	end

	def build_navigation_sitemap

	end

	## how do we do this through a rake task.
	## i should be able to do this from the controller.
	def build_sitemap
		if self.entity_id
			build_entity_sitemap
		elsif self.exchange_id
			build_exchange_sitemap
		end
	end


	private

	## @return[Stock] object
	def set_exchange
		self.exchange = Stock.find(self.exchange_id)
	end

	def set_entity
		self.entity = Stock.find(self.entity_id)
	end

	def get_entity
		self.entity
	end

	def get_exchange
		self.exchange
	end

	## call permute on entity itself.

end