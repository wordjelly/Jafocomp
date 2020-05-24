require 'test_helper'
 
class SearchTest < ActiveSupport::TestCase

   	test " -- converts patterns to icons-- " do 

   		query_string = "pattern"
   		from = 0

   		args = {
				:query => query_string,
				:direction => nil,
				:impacted_entity_id => nil,
				:from => 0
		}

   		results = Result.nested_function_score_query(args).map{|c| Result.build_setup(c)}

   		results.each do |result|
   			setup = result["_source"]["setup"]
   			assert_equal false, (setup =~ /arrow_(up|down)ward/).blank?, setup
   		end

   	end	

end