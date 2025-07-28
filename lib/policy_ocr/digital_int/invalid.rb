class PolicyOcr::DigitalInt::Invalid < PolicyOcr::DigitalInt
  def initialize(pattern:)
    @pattern = pattern
    @int_value = -1
    super()
  end

  def pattern
    @pattern
  end

  def to_s
    "?"
  end
end
