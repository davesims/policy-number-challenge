# frozen_string_literal: true

module PolicyOcr
  module Parser
    # Reads a policy document file and parses it into a PolicyOcr::Policy::Document.
    #
    # @param context [Interactor::Context] must contain file_path
    # @return [Interactor::Context] result with policy_document set on success, or error message on failure
    class ParsePolicyDocumentFile
      include Interactor
      include Interactor::Validations

      before do
        validate_presence_of(:file_path)
      end

      def call
        PolicyOcr.logger.info("Reading policy document file: #{file_path}")
        result = PolicyOcr::Parser::ParsePolicyDocumentText.call(raw_text:)

        if result.success?
          PolicyOcr.logger.info("Successfully parsed policy document: #{file_path}")
          context.policy_document = PolicyOcr::Policy::Document.new(result.policy_numbers)
        else
          PolicyOcr.logger.error("Failed to parse policy document: #{result.error}")
          context.fail!(error: "Failed to parse policy document: #{result.error}")
        end
      rescue Errno::ENOENT => e
        PolicyOcr.logger.error("File not found: #{file_path} - #{e.message}")
        context.fail!(error: e.message)
      end

      private

      def raw_text = File.read(context.file_path)
      def file_path = context.file_path
    end
  end
end
