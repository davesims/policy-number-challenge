#!/usr/bin/env ruby
# frozen_string_literal: true

require "thor"
require_relative "policy_ocr"

class PolicyOcrCLI < Thor
  def self.exit_on_failure?
    true
  end

  desc "parse FILE", "Parse policy numbers from an OCR text file"
  def parse(file)
    unless File.exist?(file)
      puts "Error: File '#{file}' not found"
      exit 1
    end
    
    begin
      result = PolicyOcr::Parser::ParsePolicyDocument.call(file_path: file)
      
      if result.success?
        puts result.policy_document
      else
        puts "Error: #{result.error}"
        exit 1
      end
    rescue => e
      puts "Error parsing file: #{e.message}"
      exit 1
    end
  end

  desc "generate", "Generate test policy numbers in ASCII art format"
  def generate
    20.times do |i|
      digits = generate_valid_number
      puts render_number(digits)
    end

    6.times do |i|
      digits = generate_invalid_digits_number
      puts render_number(digits)
    end

    4.times do |i|
      digits = generate_invalid_checksum_number
      puts render_number(digits)
    end
  end

  private

  def checksum_valid?(digits)
    return false if digits.any? { |d| d.nil? || d.is_a?(PolicyOcr::DigitalInt::Invalid) }
    policy_number = PolicyOcr::Policy::Number.new(digits.map { |d| PolicyOcr::DigitalInt.from_int(d) })
    result = PolicyOcr::ValidatePolicyNumberChecksum.call(policy_number: policy_number)
    result.success?
  end

  def generate_valid_number
    base = Array.new(8) { rand(10) }
    (0..9).each do |check_digit|
      test_digits = base + [check_digit]
      return test_digits if checksum_valid?(test_digits)
    end
    # Fallback
    [7, 1, 1, 1, 1, 1, 1, 1, 1]
  end

  def generate_invalid_digits_number
    digits = Array.new(9) { rand(10) }
    # Replace 1-2 random digits with Invalid patterns
    wrong_patterns = ["|||", " | ", "___", " _ ", "|_|", "| |", "_|_", "__|", "|__", "_| "]
    rand(1..3).times do
      digits[rand(9)] = PolicyOcr::DigitalInt::Invalid.new(pattern: wrong_patterns.sample)
    end
    digits
  end

  def generate_invalid_checksum_number
    valid_digits = generate_valid_number
    # Change the last digit to make checksum invalid
    invalid_digits = valid_digits.dup
    invalid_digits[-1] = (invalid_digits[-1] + rand(1..5)) % 10
    
    # Ensure it's actually invalid
    if checksum_valid?(invalid_digits)
      [1, 2, 3, 4, 5, 6, 7, 8, 9] # Known invalid
    else
      invalid_digits
    end
  end

  def render_number(digits)
    lines = ["", "", "", ""]
    digits.each do |digit|
      if digit.is_a?(PolicyOcr::DigitalInt::Invalid)
        # Use the invalid pattern directly
        pattern_str = digit.pattern
        pattern = pattern_str.scan(/.{3}/) # Split into chunks of 3 characters
      elsif digit.is_a?(Integer)
        digit_obj = PolicyOcr::DigitalInt.from_int(digit)
        pattern_str = digit_obj.pattern
        pattern = pattern_str.scan(/.{3}/) # Split into chunks of 3 characters
      else
        # Fallback for nil or other cases
        pattern = ["   ", "   ", "   ", "   "]
      end
      
      4.times do |i|
        lines[i] += (pattern[i] || "   ")
      end
    end
    lines.join("\n") + "\n"
  end
end

# Run the CLI if this file is executed directly
if __FILE__ == $0
  PolicyOcrCLI.start(ARGV)
end
