require 'elasticsearch/persistence/model'

class Exchange

	## we include them as concerns.
	include Elasticsearch::Persistence::Model
	include Concerns::EsBulkIndexConcern
	include Concerns::Stock::IndividualConcern
	include Concerns::Stock::CombinationConcern
	include Concerns::BackgroundJobConcern
	include Concerns::Stock::EntityConcern

	

end