require 'es'
require 'term_builder'

class EsQuery
  def initialize(question:, audience: {})
    @question = question
    @audience = audience
  end

  def execute
    ES::Client.search(index: ES::INDEX, type: :respondent, body: body)
  end

  def body
    request = {
      size: 0,
      aggs: {}
    }

    set_audience(request) if hash_present?(@audience)
    set_universe(request, @audience)
    set_options(request, @question, @audience)

    request
  end

  private

  def set_universe(request, audience)
    if hash_present?(audience)
      # TODO: need to be implemented
    else
      request[:aggs][:weighted_universe] = {
        sum: { field: :weighting }
      }
    end
  end

  def set_options(request, question, audience)
    if hash_present?(audience)
      # TODO: need to be implemented
    else
      request[:aggs][:options] = {
        terms: { field: question }
      }
    end
  end

  def set_audience(request)
    request[:query] = {
      bool: TermsBuilder.new(@audience).to_query
    }
  end

  def hash_present?(hash)
    hash.is_a?(Hash) && hash.length > 0
  end
end
