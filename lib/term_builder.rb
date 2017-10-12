class TermsBuilder
  attr_reader :audience

  def initialize(audience)
    @audience = audience
  end

  def to_query(audience = @audience)
    {
      bool: Hash[audience.map { |k,v| [k, to_term(v)] }]
    }
  end

  private

  def to_term(value)
    if value.is_a?(Array)
      value.map do |v|
        if (v.keys & [:must, :must_not, :should, :filter]).any?
          to_query(v)
        else
          {terms: v}
        end
      end
    else
      to_term([value])
    end
  end
end
