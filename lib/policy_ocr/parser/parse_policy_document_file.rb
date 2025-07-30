# frozen_string_literal: true

module PolicyOcr
  module Parser
    class ParsePolicyDocumentFile
      include Interactor
      include Interactor::Validations

      before do
        validate_presence_of(:file_path)
      end

      # Reads a policy document file and parses it into a PolicyOcr::Policy::Document.
      # This separates the responsibility of reading the file from parsing its content.
      #
      # @param context [Interactor::Context] must contain file_path
      # @return [Interactor::Context] result with policy_document set on success, or error message on failure
      def call
        PolicyOcr.logger_for(self).info("Reading policy document file: #{file_path}")
        result = PolicyOcr::Parser::ParsePolicyDocumentText.call(raw_text:)

        if result.success?
          PolicyOcr.logger_for(self).info("Successfully parsed policy document: #{file_path}")
          context.policy_document = PolicyOcr::Policy::Document.new(result.policy_numbers)
        else
          PolicyOcr.logger_for(self).error("Failed to parse policy document: #{result.error}")
          context.fail!(error: "Failed to parse policy document: #{result.error}")
        end
        context.parser_errors = result.parser_errors
      rescue Errno::ENOENT => e
        PolicyOcr.logger_for(self).error("File not found: #{file_path} - #{e.message}")
        context.fail!(error: e.message)
      end

      private

      def raw_text = File.read(context.file_path)
      def file_path = context.file_path
    end
  end
end
