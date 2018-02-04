require 'es'

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

    # Set audience unless it is the default {}
    # Audience is a portion of the universe.
    set_audience(request) if hash_present?(@audience)

    # Universe is the audience without filters applied.
    set_universe(request, @audience)

    set_options(request, @question, @audience)

    puts "finalized request %s" % [request]
    request
  end

  private

  def set_universe(request, audience)
    if hash_present?(audience)
      # Will be hit if there is an audience expression
      # TODO: need to be implemented
      puts "todo set_universe %s" % [audience]
    else
      request[:aggs][:weighted_universe] = {
        sum: { field: :weighting }
      }
    end
  end

  def set_options(request, question, audience)
    if hash_present?(audience)
      puts "todo set_options %s" % [options]
      # Will be hit if there is an audience expression
      # TODO: need to be implemented
    else
      request[:aggs][:options] = {
        terms: { field: question }
      }
    end
  end

  def set_audience(request)
    puts("todo set_audience")
    # TODO: Do the query parsing here
    # TODO: need to be implemented
  end

  # True if the value is a non-empty object.
  def hash_present?(hash)
    hash.is_a?(Hash) && hash.length > 0
  end
end
