require "mongoid-elasticsearch"

user = ENV["ES_USER"]
password = ENV["ES_PASSWORD"]
h = ENV["ES_HOST"] || "localhost"
s = ENV["ES_SCHEME"] || "http"
p = ENV["ES_PORT"] || 9200
#
host = {host: h, scheme: s, port: p}
host.merge!({user: user, password: password}) if (user && password)

Mongoid::Elasticsearch.prefix = "algorini"

Mongoid::Elasticsearch.client_options = {hosts: [host], port: p, transport_options: {headers: {"Content-Type" => "application/json" }, request: { timeout: 25 }}}

client = Elasticsearch::Client.new host: [host], request_timeout: 25
puts client.cluster.health

