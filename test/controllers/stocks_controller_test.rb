require "test_helper"

class StocksControllerTest < ActionDispatch::IntegrationTest

    
	setup do 
		## we can make it from a json dump.
		## but then that file has to be included.
		## we need to create the tradegenie index if it doesn't exists
		## and then continue.
		Stock.create_index! force: true
	end


	test " -- creates entity in the after_save callback, with the top five hits -- " do 
		put stock_path("E-1"), params: {stock: {:trigger_update => true}}.to_json, headers: { "CONTENT_TYPE" => "application/json" , "ACCEPT" => "application/json"}
		e = Stock.find("E-1")
		Elasticsearch::Persistence.client.indices.refresh index: "frontend"   
		assert_equal true, !e.stock_top_results.blank?
	end

	test " -- creates entity in after save callback with combinations with other entities --  " do 

		## so here we want its combinations where it is impacted.

	end

end