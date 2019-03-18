Elasticsearch::Persistence.client = Elasticsearch::Client.new hosts: [ {host: "192.168.1.14", scheme: "http", port: 9200}], transport_options: {headers: {"Content-Type" => "application/json" } }
