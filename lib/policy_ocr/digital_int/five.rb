class PolicyOcr::DigitalInt::Five < PolicyOcr::DigitalInt
  PATTERN = " _ " +
            "|_ " +
            " _|" +
            "   "

  def initialize
    @int_value = 5
  end
end