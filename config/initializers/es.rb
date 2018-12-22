Elasticsearch::Persistence.client = Elasticsearch::Client.new hosts: [ {host: "localhost", scheme: "http", port: 9200}], transport_options: {headers: {"Content-Type" => "application/json" } }
