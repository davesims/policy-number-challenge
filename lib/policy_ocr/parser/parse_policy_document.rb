# frozen_string_literal: true

module PolicyOcr
  module Parser
    class ParsePolicyDocument
      include Interactor

      def call
        result = PolicyOcr::Parser::ParsePolicyDocumentLines.call(raw_text:)

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
