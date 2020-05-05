require "test_helper"

class IndicatorsControllerTest < ActionDispatch::IntegrationTest

	setup do 
		Stock.create_index! force: true
		## load the elasticsearch dump file, as a base for the test.
		## 
	end

	test " -- creates indicator, and adds its information, and top search results -- " do 

		put indicators_update_many_path, params: {}.to_json, headers: { "CONTENT_TYPE" => "application/json" , "ACCEPT" => "application/json"}

		assert_equal true, Indicator.get_all.size > 0

		Indicator.get_all.each do |hit|
			assert_equal hit["_source"]["stock_top_results"].size > 0
		end

	end

	

end