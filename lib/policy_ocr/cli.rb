#!/usr/bin/env ruby
# frozen_string_literal: true

require "thor"
require_relative "../policy_ocr"

module PolicyOcr
  class Cli < Thor
    def self.exit_on_failure?
      true
    end

    desc "parse FILE", "Parse policy numbers from an OCR text file"
    def parse(file)
      validate_file_exists(file)

      result = parse_policy_file(file)
      handle_parse_result(result)
    rescue StandardError => e
      handle_parsing_error(e)
    end

    desc "generate_policy_numbers", "Generate test policy numbers in ASCII digital format"
    def generate_policy_numbers
      valid = 20.times.map do |_i|
        generate_valid_number
      end

      invalid_digits = 6.times.map do |_i|
        generate_invalid_digits_number
      end

      invalid_checksums = 4.times.map do |_i|
        generate_invalid_checksum_number
      end

      all_digits = valid + invalid_digits + invalid_checksums
      all_digits.shuffle.each do |digit|
        puts render_number(digit)
      end
    end

    private

    def validate_file_exists(file)
      return if File.exist?(file)

      puts "Error: File '#{file}' not found"
      exit 1
    end

    def parse_policy_file(file)
      PolicyOcr::Parser::ParsePolicyDocumentFile.call(file_path: file)
    end

    def handle_parse_result(result)
      if result.success?
        puts result.policy_document
        display_parser_errors(result) if result.parser_errors&.any?
      else
        puts "Error: #{result.error}"
        exit 1
      end
    end

    def display_parser_errors(result)
      puts "\nThe process encountered parser errors:"
      result.parser_errors.each { |error| puts "  - #{error}" }
    end

    def handle_parsing_error(error)
      puts "Error parsing file: #{error.message}"
      exit 1
    end

    def checksum_valid?(digital_ints)
      policy_number = PolicyOcr::Policy::Number.new(digital_ints)
      policy_number.checksum_valid?
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
          next unless (candidate * 9) % 11 == target_remainder

          result = base + [candidate]
          # Verify it's actually valid
          digital_ints = result.map { |d| PolicyOcr::DigitalInt.from_int(d) }
          return digital_ints if checksum_valid?(digital_ints)
        end
      end
    end

    def generate_invalid_digits_number
      digits = Array.new(9) { |_i| PolicyOcr::DigitalInt.from_int(rand(10)) }
      # Replace random digits with Invalid patterns
      wrong_patterns = ["|||", " | ", "___", " _ ", "|_|", "| |", "_|_", "__|", "|__", "_| "]
      rand(1..3).times do
        digits[rand(9)] = PolicyOcr::DigitalInt::Invalid.new(pattern: wrong_patterns.sample)
      end
      digits
    end

    def generate_invalid_checksum_number
      valid_digits = generate_valid_number
      # Change the last digit to make checksum invalid
      last_digit_value = valid_digits[-1].to_i
      new_digit_value = (last_digit_value + rand(1..5)) % 10
      invalid_digits[-1] = PolicyOcr::DigitalInt.from_int(new_digit_value)
      invalid_digits
    end

    def render_number(digits)
      patterns = digits.map do |digit|
        pattern = digit.pattern
        pattern = pattern.ljust(12) if pattern.length < 12
        pattern[0, 12] # Take only first 12 chars if longer
      end

      lines = patterns.map { |p| p.scan(/.{3}/) }.transpose
      "#{lines.map(&:join).join("\n")}\n"
    end
  end
end

# Run the CLI if this file is executed directly
PolicyOcr::Cli.start(ARGV) if __FILE__ == $PROGRAM_NAME
