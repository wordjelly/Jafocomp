require 'elasticsearch/persistence/model'
require 'sitemap_generator'
require 'google/cloud/storage'

class SiteMap::SiteMap

	include Elasticsearch::Persistence::Model
	include Concerns::BackgroundJobConcern
	include Concerns::EsBulkIndexConcern

	attribute :exchange_name, String, mapping: {type: 'keyword'}
	attribute :exchange_id, String, mapping: {type: 'keyword'}
	attr_accessor :exchange

	## it adds crud on its own.
	## so we make a sitemaps controller and hook it into a background job
	## today mostly cloning -> and 
	## don't allow newer categories ??? what say, that prevents fuck ups.

	CREDENTIALS_PATH = Rails.root.join("config","keys","google_cloud_storage_bhargav_r_raut@gmail.com_service_account_dark-edge-264914-3c2e40ad386e.json")

	after_save do |document|
		document.schedule_background_update
	end

	def schedule_background_update
		ScheduleJob.perform_later([self.id.to_s,self.class.name.to_s,"build_sitemap"])
	end

	## lets see if this much works or not
	## then we go to the final endpoint.
	## will have to try it on heroku itself.

	def get_exchange
		self.exchange
	end

	## how do we do this through a rake task.
	## i should be able to do this from the controller.
	def build_sitemap
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
		SitemapGenerator::Sitemap.compress = false

		SitemapGenerator::Sitemap.adapter = SitemapGenerator::GoogleStorageAdapter.new(
		  credentials: CREDENTIALS_PATH,
		  project_id: ENV["GOOGLE_CLOUD_PROJECT"],
		  bucket: "algorini"
		)

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

		#SitemapGenerator::Sitemap.ping_search_engines('https://algorini.com/sitemap.xml.gz')

	end


	private

	## @return[Stock] object
	def set_exchange
		self.exchange = Stock.find(self.exchange_id)
		puts "self exchange is:"
		puts self.exchange
	end

	## call permute on entity itself.

end