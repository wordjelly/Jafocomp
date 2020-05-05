require "test_helper"

class StocksControllerTest < ActionDispatch::IntegrationTest

	setup do 
		Stock.create_index! force: true
		## load the elasticsearch dump file, as a base for the test.
		## 
	end
	## we can download that
	## first draw the fucking chart.

	test " -- creates entity in the after_save callback, with the top five hits, and combination hits. -- " do 

		
		put stock_path("E-1"), params: {stock: {:trigger_update => true}}.to_json, headers: { "CONTENT_TYPE" => "application/json" , "ACCEPT" => "application/json"}
		
	
		Elasticsearch::Persistence.client.indices.refresh index: "frontend"  

		e = Stock.find("E-1")

		assert_equal e.stock_result_type,Stock::SINGLE,"single stocks should have a 0 result tyep" 

		assert_equal false, Stock.get_all_combination_entities.blank?

		assert_equal true, !e.stock_top_results.blank?
		
	end


	test " -- populates stock with combination nested items -- " do 

		## first create a stock 
		stock_two = Stock.find_or_initialize({id: "E-2"})
		stock_two.save
		assert_equal true, stock_two.errors.blank?

		## now create another stock, and it should populate the first stock with its combination.
		put stock_path("E-1"), params: {stock: {:trigger_update => true}}.to_json, headers: { "CONTENT_TYPE" => "application/json" , "ACCEPT" => "application/json"}
		Elasticsearch::Persistence.client.indices.refresh index: "frontend"  

		## assert that the combination was added.
		e = Stock.find("E-2")
		assert_equal 1, e.combinations.size

	end

	

end