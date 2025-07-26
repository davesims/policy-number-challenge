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

  def lines 
    raw_text
      .split(CARRIAGE_RETURN)
      .each_slice(PolicyOcr::LINE_HEIGHT)
      .to_a
  end

  def raw_text = @raw_text ||= context.raw_text
end
