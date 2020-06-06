require "test_helper"

class SitemapsControllerTest < ActionDispatch::IntegrationTest

	setup do 
		SiteMap::SiteMap.create_index! force: true 
	end
		
	test " -- creates sitemap for nifty 50 exchange, with just the nifty entity paths -- " do 
		
		post sitemap_sitemaps_path, params: {sitemap: {:exchange_name => "Nifty 50", :exchange_id => "E-9"}}.to_json, headers: { "CONTENT_TYPE" => "application/json" , "ACCEPT" => "application/json"}

	end

end