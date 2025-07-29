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

  desc "generate_policy_numbers", "Generate test policy numbers in ASCII art format"
  def generate_policy_numbers
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
    loop do
      # Generate first 8 digits randomly
      base = Array.new(8) { rand(10) }
      
      # Calculate partial sum: d1×1 + d2×2 + ... + d8×8
      partial_sum = base.each_with_index.sum { |digit, i| digit * (i + 1) }
      
      # Find d9 such that (partial_sum + d9×9) mod 11 = 0
      target_remainder = (-partial_sum) % 11
      
      (0..9).each do |candidate|
        if (candidate * 9) % 11 == target_remainder
          result = base + [candidate]
          # Verify it's actually valid
          if checksum_valid?(result)
            return result.map { |d| PolicyOcr::DigitalInt.from_int(d) }
          end
        end
      end
      
      # If no valid candidate found, try new base digits
    end
  end


  def generate_invalid_digits_number
    digits = Array.new(9) { |i| PolicyOcr::DigitalInt.from_int(rand(10)) }
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
    last_digit_value = invalid_digits[-1].to_i
    new_digit_value = (last_digit_value + rand(1..5)) % 10
    invalid_digits[-1] = PolicyOcr::DigitalInt.from_int(new_digit_value)
    
    invalid_digits
  end

  def render_number(digits)
    patterns = digits.map do |digit|
      pattern = digit.pattern
      # Ensure pattern is exactly 12 characters (4 lines × 3 chars)
      pattern = pattern.ljust(12) if pattern.length < 12
      pattern[0, 12] # Take only first 12 chars if longer
    end
    
    lines = patterns.map { |p| p.scan(/.{3}/) }.transpose
    lines.map { |line| line.join }.join("\n") + "\n"
  end
end

# Run the CLI if this file is executed directly
if __FILE__ == $0
  PolicyOcrCLI.start(ARGV)
end
