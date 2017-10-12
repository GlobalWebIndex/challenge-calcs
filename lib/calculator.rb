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
    es_result['aggregations']['weighted_universe']
  end

  def parse_result(es_result, universe)
    es_result['aggregations']['options']['buckets'].map{|o| calc_option(o, universe)}
  end

  def calc_option(option_result, universe)
    {
      option: option_result['key'],
      responses_count: option_result['doc_count'],
      weighted: option_result['weighted']['value']
    }
  end
end
