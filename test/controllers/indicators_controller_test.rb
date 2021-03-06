require "test_helper"

class IndicatorsControllerTest < ActionDispatch::IntegrationTest

	setup do 
		Indicator.create_index! force: true
	end

	test " -- creates indicator, and adds its information, and top search results -- " do 

		put indicators_update_many_path, params: {}.to_json, headers: { "CONTENT_TYPE" => "application/json" , "ACCEPT" => "application/json"}

		assert_equal true, Indicator.get_all.size > 0

		Elasticsearch::Persistence.client.indices.refresh index: "frontend*"	
		## you need proper flow logging

		Indicator.get_all.each do |hit|
			#puts hit.to_s
			assert_equal true, hit["_source"]["stock_top_results"].size > 0
			indicator_name = hit["_source"]["stock_name"]

			## what do we do about patterns.
			## and when there is an indicator -> 
			## we want it to be with an apostrophe's 
			## in meta's
			## 

			if indicator_name =~ /_/
				hit["_source"]["stock_top_results"].each do |result|
						
					assert_equal true, (result._source.setup =~ /#{indicator_name}/).blank?, "the indicator name should not be in the setup"

				end
			end
		end

	end


=begin
	test " -- creates indicator combinations with each stock -- " do 

		stock_two = Stock.find_or_initialize({id: "E-2", :trigger_update => true})
		stock_two.save
		Elasticsearch::Persistence.client.indices.refresh index: "frontend"  
		stock_two = Stock.find("E-2")
		assert_equal true, stock_two.errors.blank?
		assert_equal true, !stock_two.stock_top_results.blank?
		assert_equal true, stock_two.combinations.blank?


		put indicators_update_many_path, params: {}.to_json, headers: { "CONTENT_TYPE" => "application/json" , "ACCEPT" => "application/json"}

		assert_equal true, Indicator.get_all.size > 0

		Elasticsearch::Persistence.client.indices.refresh index: "frontend*"   

		e = Stock.find("E-2")
		assert_equal 1, e.combinations.size

	end
=end
	

end