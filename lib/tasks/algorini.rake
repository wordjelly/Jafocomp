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
        #Stock.create_index! force: true
        #aggs = Inventory::Item.items_count_by_item_group("Pathofast-5e7e7b29acbcd678ed0903c49768ef")

        #l = JSON.parse($redis.get("week_changes_obj"))
        #IO.write("jj.json",JSON.pretty_generate(l))
        #User.setup

    end

end