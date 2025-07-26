require 'interactor'
require 'pry'

class PolicyOcr
  DIGITS_PER_LINE = 9.freeze
  DIGIT_WIDTH = 3.freeze
  DIGIT_HEIGHT = 4.freeze

  include Interactor

  def call
    raw_text = File.read(context.file_path)
    result = PolicyOcr::ReadLines.call(raw_text:)
    result.all_digits.each do |line|
      puts line.map(&:to_i).join(", ")
    end

    result.all_digits.each do |line|
      line.each do |digit|
        digit.print_pattern
      end
    end
  rescue StandardError => e
    context.fail!(error: e.message)
  end
end

require_relative "policy_ocr/digital_int"
require_relative 'policy_ocr/parse_line'
require_relative 'policy_ocr/read_lines'


result = PolicyOcr.call(file_path: './spec/fixtures/sample.txt')
if result.success?
  puts "Successfully read the file."
  puts "Numbers: #{result.inpect}"
else
  puts "Failed to read the file: #{result.error}"
end
