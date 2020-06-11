namespace :algorini do
  
    desc "creates all stocks, and indicators "

    task setup: :environment do 

    	Stock.create_index! force: true
    	Indicator.create_index! force: true

    	Rails.logger.debug("creating stocks")
    	10.times do |t|
			stock = Stock.find_or_initialize({id: "E-#{t}", trigger_update: true})
			stock.save
		end

		Rails.logger.debug("creating indicators")
		Indicator.update_many

    end

    task sitemap: :environment do 
        sitemap = SiteMap::SiteMap.new({:exchange_name => "Nifty 50", :exchange_id => "E-9"})
        sitemap.save
    end

end