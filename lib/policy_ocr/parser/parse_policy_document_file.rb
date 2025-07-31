# frozen_string_literal: true

module PolicyOcr
  module Parser
    class ParsePolicyDocumentFile
      include Interactor
      include Interactor::Validations

      before do
        validate_presence_of(:file_path)
        validate("File '#{context.file_path}' not found") { File.exist?(context.file_path) }
      end

      # Reads a policy document file and parses it into a PolicyOcr::Policy::Document.
      # This separates the responsibility of reading the file from parsing its content.
      #
      # @param context [Interactor::Context] must contain file_path
      # @return [Interactor::Context] result with policy_document set on success, or error message on failure
      def call
        logger.info("Reading policy document file: #{file_path}")
        handle_parse_result(parse_document_text)
      rescue Errno::ENOENT => e
        logger.error("File not found: #{file_path} - #{e.message}")
        context.fail!(error: e.message)
      end

      private

      def parse_document_text
        PolicyOcr::Parser::ParsePolicyDocumentText.call(raw_text:)
      end

      def handle_parse_result(result)
        if result.success?
          logger.info("Successfully parsed policy document: #{file_path}")
          context.policy_document = PolicyOcr::Policy::Document.new(result.policy_numbers)
        else
          logger.error("Failed to parse policy document: #{result.error}")
          context.fail!(error: "Failed to parse policy document: #{result.error}")
        end
        context.parser_errors = result.parser_errors
      end

      def raw_text
        File.read(context.file_path)
      end

      def file_path
        context.file_path
      end

      def logger
        PolicyOcr.logger_for(self)
      end
    end
  end
end
