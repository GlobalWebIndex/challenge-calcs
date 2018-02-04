require 'es_query'

class Calculator
  attr_reader :result

  def initialize(question:, audience: {})
    puts
    puts
    es_result = EsQuery.new(question: question, audience: audience).execute
    universe = get_universe(es_result)
    buckets = get_buckets(es_result)
    puts "universe %s" % [universe]
    puts "buckets %s" % [buckets]
    @result = parse_result(buckets, universe)
    puts "result %s" % [@result]
  end

  private

  def get_universe(es_result)
    es_result['aggregations']['weighted_universe']
  end

  def get_buckets(es_result)
    es_result['aggregations']['options']['buckets']
  end

  def parse_result(options, universe)
    options.map{|o| calc_option(o, universe)}
  end

  def calc_option(option_result, universe)
    {
      option: option_result['key'],
      responses_count: option_result['doc_count'],
      weighted: option_result['weighted_bucket']['value'],
      percentage: ((option_result['weighted_bucket']['value'] / universe['value']) * 100).round(2)
    }
  end
end
