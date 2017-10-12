class TermsBuilder
  attr_reader :audience

  def initialize(audience)
    @audience = audience
  end

  def to_query
    Hash[@audience.map { |k,v| [k, to_term(v)] }]
  end

  private

  def to_term(value)
    if value.is_a?(Array)
      value.map { |v| {terms: v}}
    else
      to_term([value])
    end
  end
end
