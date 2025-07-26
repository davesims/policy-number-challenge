class PolicyOcr::ReadLines
  include Interactor

  CARRIAGE_RETURN = "\n".freeze

  def call
    all_digits = lines.map do |line|
      PolicyOcr::ParseLine.call(line:).digits
    end
    context.all_digits = all_digits
  end
  
  private

  # From the raw text, extract an array of lines.
  def lines 
    context.raw_text.split(CARRIAGE_RETURN)
      .each_slice(PolicyOcr::DIGIT_HEIGHT)
      .to_a
  end
end
