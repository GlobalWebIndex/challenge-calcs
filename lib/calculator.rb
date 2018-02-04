require 'es'
require 'es_query'

class Calculator
  attr_reader :result

  def initialize(question:, audience: {})
    #puts
    #puts
    request = EsQueryMaker.new(question: question, audience: audience).make
    #puts "request %s" % [request]
    response = ES::Client.search(index: ES::INDEX, type: :respondent, body: request)
    #puts "response %s" % [response]

    universe = response['aggregations']['weighted_universe']['value']
    #puts "universe %s" % [universe]
    buckets = response['aggregations']['options']['buckets']
    #puts "buckets %s" % [buckets]
    @result = buckets.map{|o| calc_option(o, universe)}
    #puts "result %s" % [@result]
  end

  private

  def calc_option(option_result, universe)
    {
      option: option_result['key'],
      responses_count: option_result['doc_count'],
      weighted: option_result['weighted_bucket']['value'],
      percentage: ((option_result['weighted_bucket']['value'] / universe) * 100).round(2)
    }
  end
end
