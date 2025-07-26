require 'interactor'
require 'pry'

class PolicyOcr
  DIGITS_PER_LINE = 9.freeze
  DIGIT_WIDTH = 3.freeze
  LINE_HEIGHT = 4.freeze

  include Interactor

  def call
    raw_text = File.read(context.file_path)
    result = PolicyOcr::ReadLines.call(raw_text:)
    result.all_digits.each do |line|
      puts line.map(&:to_i).join(", ")
    end
  rescue StandardError => e
    context.fail!(error: e.message)
  end
end

# Load base classes first
require_relative 'policy_ocr/digital_int'
require_relative 'policy_ocr/parse_line'
require_relative 'policy_ocr/read_lines'

# Load digit classes after base class
require_relative 'policy_ocr/digital_int/zero'
require_relative 'policy_ocr/digital_int/one'
require_relative 'policy_ocr/digital_int/two'
require_relative 'policy_ocr/digital_int/three'
require_relative 'policy_ocr/digital_int/four'
require_relative 'policy_ocr/digital_int/five'
require_relative 'policy_ocr/digital_int/six'
require_relative 'policy_ocr/digital_int/seven'
require_relative 'policy_ocr/digital_int/eight'
require_relative 'policy_ocr/digital_int/nine'


result = PolicyOcr.call(file_path: './spec/fixtures/sample.txt')
if result.success?
  puts "Successfully read the file."
  puts "Numbers: #{result.inpect}"
else
  puts "Failed to read the file: #{result.error}"
end
