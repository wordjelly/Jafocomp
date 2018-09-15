require "mongoid-elasticsearch"

es_host = ENV["BONSAI_URL"] || "localhost"
es_port = ENV["BONSAI_URL"].nil? ? 9200 : 443


Mongoid::Elasticsearch.prefix = "algorini"

Mongoid::Elasticsearch.client_options = {hosts: [es_host], port: es_port, transport_options: {headers: {"Content-Type" => "application/json" }, request: { timeout: 25 }}}
