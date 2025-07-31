# frozen_string_literal: true

module PolicyOcr
  # rubocop:disable Style/ClassAndModuleChildren
  # Using compact style to avoid conflict with Cli class that inherits from Thor
  class Cli::PrintReport
    # rubocop:enable Style/ClassAndModuleChildren
    include Interactor
    include Interactor::Validations

    before do
      validate_presence_of(:result, :input_file, :log_file)
      validate_presence_of(:output_file) if success_case?
    end

    # Generates and displays parsing reports for both success and error cases.
    #
    # For success cases, displays statistics from the policy document including
    # counts of valid, invalid digit, and checksum error policy numbers.
    #
    # For error cases, displays helpful error information and troubleshooting tips.
    #
    # @param context [Interactor::Context] must contain result, input_file, log_file, and:
    #   - output_file (for success cases)
    # @return [Interactor::Context] always succeeds (just displays output)
    def call
      display_header
      display_files_section
      display_content_section
      display_footer
    end

    private

    def success_case?
      context.result.success?
    end

    def error_case?
      !context.result.success?
    end

    def parser_errors?
      success_case? && context.result.parser_errors&.any?
    end

    def display_header
      puts "\n#{'=' * 60}"
      puts generate_header_text
      puts "=" * 60
    end

    def generate_header_text
      filename = File.basename(context.input_file)

      if error_case?
        "❌ UNABLE TO PARSE #{filename}"
      elsif parser_errors?
        "⚠️  PARSED #{filename} WITH ERRORS"
      else
        "✅ SUCCESSFULLY PARSED #{filename}"
      end
    end

    def display_files_section
      puts
      puts "📄 Input File: #{context.input_file}"
      puts "📝 Output File: #{context.output_file}" if success_case?
      puts "📋 Log File: #{context.log_file}"
      puts
    end

    def display_content_section
      if success_case?
        display_statistics
        display_parser_errors if parser_errors?
      else
        display_error_details
      end
    end

    def display_statistics
      doc = context.result.policy_document
      puts "📈 PARSING STATISTICS:"
      puts "  Total Lines Parsed: #{doc.total_count}"
      puts "  ✅ Valid Numbers: #{doc.valid_count}"
      puts "  ❌ Checksum Errors (ERR): #{doc.err_count}"
      puts "  ❓ Invalid Digits (ILL): #{doc.ill_count}"
    end

    def display_parser_errors
      puts
      puts "⚠️  PARSER ERRORS ENCOUNTERED:"
      context.result.parser_errors.each_with_index do |error, index|
        puts "  #{index + 1}. #{error}"
      end
    end

    def display_error_details
      puts "❌ Error: #{context.result.error}"
      puts
      puts "💡 Please check that the file exists and contains valid policy number data."
      puts "💡 Check the log file for detailed error information."
    end

    def display_footer
      puts
      puts "✨ Parsing completed successfully!" if success_case?
      puts "=" * 60
    end
  end
end
