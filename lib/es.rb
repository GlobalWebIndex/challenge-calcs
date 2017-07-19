require 'elasticsearch'

module ES
  INDEX = :survey
  Client = Elasticsearch::Client.new host: ENV['ELASTICSEARCH_URL']
end
