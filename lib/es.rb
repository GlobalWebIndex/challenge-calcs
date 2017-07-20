require 'elasticsearch'

module ES
  INDEX = :survey
  Client = Elasticsearch::Client.new host: ENV['ELASTIC_URL']
end
