require 'es'

# https://www.elastic.co/guide/en/elasticsearch/reference/2.3/query-dsl-bool-query.html ?
# https://www.elastic.co/guide/en/elasticsearch/reference/2.3/search-aggregations-metrics.html


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

    puts "query %s" % [request[:aggs]]
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
      puts "todo set_options %s %s" % [question, audience]
      # Will be hit if there is an audience expression
      # TODO: need to be implemented
    else
      # https://www.elastic.co/guide/en/elasticsearch/reference/2.3/search-aggregations-bucket-terms-aggregation.html
      request[:aggs][:options] = {
        terms: { field: question },
        aggs: { weighted_bucket: { sum: { field: 'weighting' } } }
      }
    end
  end

  def set_audience(request)
    puts("todo set_audience")
    # TODO: Do the query parsing here
    # TODO: need to be implemented
    # TODO: Somehow use filter here, like bool query or something like that
    # The filter structure should be based on the audience query structure
    # "translated" to the ES query DSL as opposed to me parsing the audience
    # query structure and transforming it in a significant way
    # Some recursion magic and a little wrapping should get me there
    request[]
  end

  # True if the value is a non-empty object.
  def hash_present?(hash)
    hash.is_a?(Hash) && hash.length > 0
  end
end
