require 'elasticsearch/persistence/model'
require 'sitemap_generator'
require 'google/cloud/storage'

class SiteMap::SiteMap

	include Elasticsearch::Persistence::Model
	include Concerns::EsBulkIndexConcern

	attribute :exchange_name, String, mapping: {type: 'keyword'}
	attribute :exchange_id, String, mapping: {type: 'keyword'}

	## it adds crud on its own.


	CREDENTIALS_PATH = Rails.root.join("config","keys","google_cloud_storage_bhargav_r_raut@gmail.com_service_account_dark-edge-264914-3c2e40ad386e.json")


	def build_sitemap
		## so now let me focus on generating this shite.
		SitemapGenerator::Sitemap.create do
			get_exchange.entities.each do |exchange_entity|
		  		add '/home', :changefreq => 'daily', :priority => 0.9
			end
		end

		## add the stock pages, indicator pages and exchange pages.
		## and then test it.
		SitemapGenerator::Sitemap.create do
			all_other_stocks = stocks_by_index
			all_indicators = Indicator.get_all
			get_exchange.entities.each do |exchange_entity|
				
				## entity page.
				add Rails.application.routes.url_helpers.stock_path(exchange_entity.name), :changefreq => "daily", :priority => 0.9

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

			end
		end


	end


	private

	## @return[Stock] object
	def get_exchange
		self.exchange = Stock.find(self.exchange_id)
	end

	## call permute on entity itself.

end