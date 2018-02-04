require 'es_query'

class Calculator
  attr_reader :result

  def initialize(question:, audience: {})
    es_result = EsQuery.new(question: question, audience: audience).execute
    puts "eq_result %s" % [es_result]
    universe = get_universe(es_result)
    puts "universe %s" % [universe]
    @result = parse_result(es_result, universe)
    puts "result %s" % [result]
  end

  private

  def get_universe(es_result)
    es_result['aggregations']['weighted_universe']
  end

  def parse_result(es_result, universe)
    es_result['aggregations']['options']['buckets'].map{|o| calc_option(o, universe)}
  end

  def calc_option(option_result, universe)
    {
      option: option_result['key'],
      responses_count: option_result['doc_count'],
      weighted: 0,
      percentage: (weighted / universe) * 100
    }
  end
end
