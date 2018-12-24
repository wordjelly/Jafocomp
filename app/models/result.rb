require 'elasticsearch/persistence/model'

class Result
	include Mongoid::Document
	#include Mongoid::Elasticsearch
  	#elasticsearch!
	include Elasticsearch::Persistence::Model
	field :setup, type: String
	field :setup_exit, type: String
	field :triggered_at, type: Integer
	## should have a field called, action, that is inferred from the user query, like 'buy' or 'sell'
	## 0 -> buy
	## 1 -> sell
	field :trade_action, type: Integer
	field :trade_action_name, type: String
	field :trade_action_end, type: Integer
	field :trade_action_end_name, type: String
	embeds_many :impacts, :class_name => "Impact"

	## default values for prefix and context are provided in the method as '' and [] respectively.
	def self.suggest_r(args)
		
		args[:prefix] ||= ''
		args[:context] ||= []

		body = {
				suggest: {
					correlation_suggestion: {
						text: args[:prefix],
						completion: {
			                field: "suggest",
			                size: 10
			            }
					}
				}
			}


		body[:suggest][:correlation_suggestion][:completion][:contexts] = {
			"chain" => args[:context]
		} unless args[:context].blank?



		results = gateway.client.search index: "correlations", body: body
		
		puts JSON.pretty_generate(results)
		if results["suggest"]
			results["suggest"]["correlation_suggestion"][0]["options"]
		else
			[]
		end
		
	end

end