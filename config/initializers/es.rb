remote_host = {host: ENV["REMOTE_ES_HOST"] , scheme: 'https', port: 9243}
remote_host.merge!({user: ENV["REMOTE_ES_USER"], password: ENV["REMOTE_ES_PASSWORD"]})

host = {host: 'localhost', scheme: 'http', port: 9200}

host = Rails.env.development? ? host : remote_host

Elasticsearch::Persistence.client = Elasticsearch::Client.new hosts: [ host], headers: {"Content-Type" => "application/json" }, request: { timeout: 145 }, transport_options: {headers: {"Content-Type" => "application/json"}}

