# frozen_string_literal: true

# This class is responsible for parsing a single line of digits from the OCR output.
# It extracts the digits from a 27-character wide line and returns them as an array of strings.
# Each string represents a digit in a flattened 3x3 format.
class PolicyOcr::ParseLine
  include Interactor

  def call
    context.digits = digits
  end

  # Returns an array of 9 strings that each represent the flattened 3x3 digit representations
  # extracted from the 27x3 line that was given in context.line
  def digits
    digital_number_strings.map do |digital_number_string|
      PolicyOcr::DigitalInt.from_string(digital_number_string)
    end
  end

  def digital_number_strings
    line
      .map(&:chars)
      .map {|l| l.each_slice(PolicyOcr::DIGIT_WIDTH).to_a }
      .transpose
      .map(&:join)
  end

  def line = @line ||= context.line
end
