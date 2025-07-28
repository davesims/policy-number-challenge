# frozen_string_literal: true

module PolicyOcr
  module Parser
    class ParsePolicyDocument
      include Interactor

      def call
        raw_text = File.read(context.file_path)
        result = PolicyOcr::Parser::ParsePolicyDocumentLines.call(raw_text:)
        policy_document = PolicyOcr::Policy::Document.new(result.all_policy_numbers)
        context.policy_document = policy_document
      end
    end
  end
end
