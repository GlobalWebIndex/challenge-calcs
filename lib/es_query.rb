class EsQueryMaker
  def initialize(question:, audience:)
    @question = question
    @audience = audience
    @hasAudience = audience.is_a?(Hash) && audience.length > 0
  end

  def make
    request = {
      size: 0, # Only return aggregation results, not the actual document collection results.
      aggs: {
        weighted_universe: {
          sum: {
            field: :weighting # This will work over the current audience (universe if `{}`), so besides applying `query`, we don't need to do anything extra here.
          }
        }
      }
    }

    if @hasAudience
      # This modifies `audience` in place, so we do not guarantee not touching it to the called. In Rust's semantics, this is a move.
      #puts 'Ruby expression: %s' % [@audience]
      convertAudienceExpressionToFilterExpression(@audience)
      #puts 'ES expression: %s' % [@audience]
      request[:query] = {
        filtered: {
          filter: @audience
        }
      }
      
    end

    # Aggregate by the question and compute total weighing for each bucket.
    request[:aggs][:options] = {
      terms: {
        field: @question # This will actually bucket the aggregated results by the unique values of the `question` field.
      },
      aggs: {
        weighted_bucket: {
          sum: {
            field: :weighting # This will compute the total weighting in the bucket as opposed to the entire audience.
          }
        }
      }
    }

    request
  end

  private

  def convertAudienceExpressionToFilterExpression(hash)
    raise 'Hash must have exactly one key' if (hash.length != 1)

    key = hash.keys[0]
    case "#{key}" # .to_s?
      when 'or' # Nothing changes, `or` is the same in ES
        hash[key].each { |item| convertAudienceExpressionToFilterExpression(item) }
      when 'and' # Nothing changes, `and` is the same in ES
        hash[key].each { |item| convertAudienceExpressionToFilterExpression(item) }
      else
        # Wrap in the `terms` query
        value = hash[key]
        hash.delete(key)
        hash[:terms] = {}
        hash[:terms][key] = value
    end
  end

end
