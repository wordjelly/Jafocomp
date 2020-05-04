module Concerns::Stock::IndividualConcern
	
	extend ActiveSupport::Concern

	included do 

		def update_top_results
			if self.information_type == "entity"
				self.stock_top_results = Result.nested_function_score_query("",nil,self.id.to_s)[0..4].map{|c| Result.build_setup(c) }
			elsif self.information_type == "indicator"
				self.stock_top_results = Result.nested_function_score_query(self.stock_name,nil,nil)[0..4].map{|c| Result.build_setup(c) }
			end
			## this is with the top_results
			## now we have the next step.
			## make it visible with the charts.
			#puts "these are the stock top results"
			#puts self.stock_top_results.to_s
		end

		## can we create 

	end

end