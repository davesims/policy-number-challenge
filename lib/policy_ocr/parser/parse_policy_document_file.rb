# frozen_string_literal: true

module PolicyOcr
  module Parser
    # Takes a file path on context and reads the file, into raw_text,
    # then parses the text into a PolicyOcr::Policy::Document, which is
    # returned on result.policy_document.
    class ParsePolicyDocumentFile
      include Interactor

      def call
        result = PolicyOcr::Parser::ParsePolicyDocumentText.call(raw_text:)

        if result.success?
          context.policy_document = PolicyOcr::Policy::Document.new(result.all_policy_numbers)
        else
          context.fail!(error: "Failed to parse policy document: #{result.error}")
        end
      end

      private

      def raw_text = File.read(context.file_path)
      def file_path = context.file_path
    end
  end
end
