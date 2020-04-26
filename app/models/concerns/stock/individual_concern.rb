module Concerns::Stock::IndividualConcern
	
	extend ActiveSupport::Concern

	included do 

		def update_top_results
			## okay so what is the query ?
			## match_all?
			## how many more years will this take ?
			self.stock_top_results = Result.nested_function_score_query("",nil,self.id.to_s)[0..4]
			puts "these are the stock top results"
			puts self.stock_top_results.to_s
		end

	end

end