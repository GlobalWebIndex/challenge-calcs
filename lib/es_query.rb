require 'es'

class EsQuery
  def initialize(question:, audience:)
    @question = question
    @audience = audience
    @hasAudience = audience.is_a?(Hash) && audience.length > 0
  end

  def execute
    ES::Client.search(index: ES::INDEX, type: :respondent, body: body)
  end

  def body
    request = { size: 0, aggs: {} }
    set_audience(request)
    set_universe(request)
    set_options(request)

    puts "query %s" % [request[:aggs]]
    request
  end

  private

  def set_audience(request)
    if @hasAudience
      # TODO: Actually walk `@audience` and build a `bool` query instead of the `filtered` query.
      request[:filtered][:filter] = @audience
    end
  end

  def set_universe(request)
    if @hasAudience
      # TODO: Use proper `bool` query and not the literal `@audience` query
      request[:filtered][:filter] = @audience
      # TODO: Carry over the overall weighted_universe aggregation somehow
    else
      request[:aggs][:weighted_universe] = {
        sum: { field: :weighting }
      }
    end
  end

  def set_options(request)
    if @hasAudience
      # TODO: Actually walk `@audience` and build a `bool` query instead of the `filtered` query.
      request[:filtered][:filter] = @audience
    else
      request[:aggs][:options] = {
        terms: { field: @question },
        aggs: { weighted_bucket: { sum: { field: 'weighting' } } }
      }
    end
  end

end
