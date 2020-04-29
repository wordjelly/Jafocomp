require "test_helper"

class StocksControllerTest < ActionDispatch::IntegrationTest

	setup do 
		Stock.create_index! force: true
	end


	test " -- creates entity in the after_save callback, with the top five hits, and combination hits. -- " do 

		put stock_path("E-1"), params: {stock: {:trigger_update => true}}.to_json, headers: { "CONTENT_TYPE" => "application/json" , "ACCEPT" => "application/json"}
		
		e = Stock.find("E-1")
			
		## assign missing
		## category sufficient ?
		## removal of items
		## removal of reports
		## and all the other tests.

		Elasticsearch::Persistence.client.indices.refresh index: "frontend"  

		assert_equal e.stock_result_type,Stock::SINGLE,"single stocks should have a 0 result tyep" 

		assert_equal false, Stock.get_all_combination_entities.blank?

		assert_equal true, !e.stock_top_results.blank?
		
	end

end