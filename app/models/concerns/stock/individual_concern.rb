module Concerns::Stock::IndividualConcern
	
	extend ActiveSupport::Concern

	included do 

		def update_top_results
				
			
			self.stock_top_results = Result.nested_function_score_query("",nil,self.id.to_s)[0..4].map{|c| Result.build_setup(c) }
		
		end

		## can we create 

	end

end