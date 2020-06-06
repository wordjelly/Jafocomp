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

	def build_sitemap
		set_exchange
		Rails.logger.debug("came to create sitemap, with self exchange :#{self.exchange.id.to_s}")
		all_other_stocks = get_exchange.get_all_other_stocks
		all_indicators = Indicator.get_all
		exchange_entities = get_exchange.entities

		# Your website's host name
		SitemapGenerator::Sitemap.default_host = "http://www.algorini.com"

		# The remote host where your sitemaps will be hosted
		SitemapGenerator::Sitemap.sitemaps_host = "https://console.cloud.google.com/storage/browser/algorini"

		# The directory to write sitemaps to locally
		SitemapGenerator::Sitemap.public_path = 'tmp/'

		# Set this to a directory/path if you don't want to upload to the root of your `sitemaps_host`
		SitemapGenerator::Sitemap.sitemaps_path = 'sitemaps/'


		SitemapGenerator::Sitemap.adapter = SitemapGenerator::GoogleStorageAdapter.new(
		  credentials: CREDENTIALS_PATH,
		  project_id: ENV["GOOGLE_CLOUD_PROJECT"],
		  bucket: "algorini"
		)


		## so now let me focus on generating this shite.
		## add the stock pages, indicator pages and exchange pages.
		## and then test it.
		SitemapGenerator::Sitemap.create do
			
			exchange_entities.each do |exchange_entity|
				
				## entity page.
				add Rails.application.routes.url_helpers.stock_path(exchange_entity.name), :changefreq => "daily", :priority => 0.9

=begin
				## trend directions.
				Concerns::Stock::EntityConcern::TREND_DIRECTIONS.each do |td|
					add Rails.application.routes.url_helpers.direction_entity_path(exchange_entity.name,td), :changefreq => "daily", :priority => 0.9
				end
					
				## indicator combinations.
				all_indicators.each do |indicator| 
					add Rails.application.routes.url_helpers.combination_indicator_path(impacted_stock.name,exchange_entity.name,), :changefreq => "daily", :priority => 0.9
				end

				## other entity combinations.
				all_other_stocks.keys.each do |exchange_name|
					all_other_stocks[exchange_name].each do |impacted_stock|
						## combination path
						## entity path.
						add Rails.application.routes.url_helpers.combination_entity_path(impacted_stock.name,exchange_entity.name), :changefreq => "daily", :priority => 0.9
					end
				end
=end


			end
		end


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