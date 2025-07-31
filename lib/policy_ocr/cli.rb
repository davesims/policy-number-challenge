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
      setup_logging(file)

      result = parse_policy_file(file)
      handle_parse_result(result, file)
    rescue StandardError => e
      handle_parsing_error(e)
    end

    desc "generate_policy_numbers", "Generate test policy numbers in ASCII digital format"
    def generate_policy_numbers
      numbers = Array.new(20) { generate_valid_number } +
                Array.new(6) { generate_invalid_digits_number } +
                Array.new(4) { generate_invalid_checksum_number }
      
      puts numbers.shuffle.map { |number| render_number(number) }
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

    def handle_parse_result(result, input_file)
      if result.success?
        output = result.policy_document.to_s
        output_file = write_output_file(output, input_file)
        log_file = get_log_file_path(input_file)
        display_parsing_report(result, input_file, output_file, log_file)
      else
        log_file = get_log_file_path(input_file)
        display_error_report(input_file, result.error, log_file)
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

    def display_error_report(input_file, error_message, log_file)
      filename = File.basename(input_file)
      puts "\n" + "=" * 60
      puts "❌ UNABLE TO PARSE #{filename}"
      puts "=" * 60
      puts
      puts "📄 Input File: #{input_file}"
      puts "📋 Log File: #{log_file}"
      puts "❌ Error: #{error_message}"
      puts
      puts "💡 Please check that the file exists and contains valid policy number data."
      puts "💡 Check the log file for detailed error information."
      puts "=" * 60
    end

    def setup_logging(input_file)
      log_file = get_log_file_path(input_file)
      PolicyOcr.set_log_path(log_file)
    end

    def get_log_file_path(input_file)
      output_dir = "parsed_files"
      Dir.mkdir(output_dir) unless Dir.exist?(output_dir)
      
      base_name = File.basename(input_file, ".*")
      File.join(output_dir, "parsed_#{base_name}.log")
    end

    def write_output_file(output, input_file)
      output_dir = "parsed_files"
      Dir.mkdir(output_dir) unless Dir.exist?(output_dir)
      
      base_name = File.basename(input_file, ".*")
      output_filename = File.join(output_dir, "#{base_name}_parsed.txt")
      File.write(output_filename, output)
      output_filename
    end

    def display_parsing_report(result, input_file, output_file, log_file)
      policy_numbers = result.policy_document.policy_numbers
      total_count = policy_numbers.size
      valid_count = policy_numbers.count { |pn| pn.message.empty? }
      err_count = policy_numbers.count { |pn| pn.message == "ERR" }
      ill_count = policy_numbers.count { |pn| pn.message == "ILL" }
      
      filename = File.basename(input_file)
      has_parser_errors = result.parser_errors&.any?
      
      header = if has_parser_errors
                 "⚠️  PARSED #{filename} WITH ERRORS"
               else
                 "✅ SUCCESSFULLY PARSED #{filename}"
               end
      
      puts "\n" + "=" * 60
      puts header
      puts "=" * 60
      puts
      puts "📄 Input File: #{input_file}"
      puts "📝 Output File: #{output_file}"
      puts "📋 Log File: #{log_file}"
      puts
      puts "📈 PARSING STATISTICS:"
      puts "  Total Lines Parsed: #{total_count}"
      puts "  ✅ Valid Numbers: #{valid_count} (#{percentage(valid_count, total_count)}%)"
      puts "  ❌ Checksum Errors (ERR): #{err_count} (#{percentage(err_count, total_count)}%)"
      puts "  ❓ Invalid Digits (ILL): #{ill_count} (#{percentage(ill_count, total_count)}%)"
      
      if result.parser_errors&.any?
        puts
        puts "⚠️  PARSER ERRORS ENCOUNTERED:"
        result.parser_errors.each_with_index do |error, index|
          puts "  #{index + 1}. #{error}"
        end
      end
      
      puts
      puts "✨ Parsing completed successfully!"
      puts "=" * 60
    end

    def percentage(count, total)
      return 0 if total.zero?
      ((count.to_f / total) * 100).round(1)
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
      # Replace random digits with Invalid patterns (3x3 = 9 chars each)
      wrong_patterns = ["|||   |||", " |    |  ", "___   ___", " _    _  ", "|_|   |_|", "| |   | |", "_|_   _|_", "__|   __|", "|__   |__", "_|    _| "]
      rand(1..3).times do
        digits[rand(9)] = PolicyOcr::DigitalInt::Invalid.new(pattern: wrong_patterns.sample)
      end
      digits
    end

    def generate_invalid_checksum_number
      valid_digits = generate_valid_number
      # Change the last digit to make checksum invalid
      last_digit_value = valid_digits[-1].to_i
      invalid_digit_value = (last_digit_value + rand(1..5)) % 10
      valid_digits[-1] = PolicyOcr::DigitalInt.from_int(invalid_digit_value)
      valid_digits
    end

    def render_number(digits)
      patterns = digits.map(&:pattern)
      lines = patterns.map { |p| p.scan(/.{3}/) }.transpose
      "#{lines.map(&:join).join("\n")}\n"
    end
  end
end

# Run the CLI if this file is executed directly
PolicyOcr::Cli.start(ARGV) if __FILE__ == $PROGRAM_NAME
