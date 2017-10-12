require 'es_query'

class Calculator
  attr_reader :result

  def initialize(question:, audience: {})
    es_result = EsQuery.new(question: question, audience: audience).execute

    universe = get_universe(es_result)
    @result = parse_result(es_result, universe)
  end

  private

  def get_universe(es_result)
    es_result['aggregations']['weighted_universe']['value']
  end

  def parse_result(es_result, universe)
    es_result['aggregations']['options']['buckets'].map{|o| calc_option(o, universe)}
  end

  def calc_option(option_result, universe)
    weighted = option_result['weighted']['value']

    {
      option: option_result['key'],
      responses_count: option_result['doc_count'],
      weighted: weighted.to_i,
      percentage: universe == 0.0 ? 0 : (weighted / universe * 100).round(2)
    }
  end
end
