# frozen_string_literal: true

module PolicyOcr
  module Parser
    class ParsePolicyDocumentLines
      include Interactor

      def call
        all_policy_numbers = lines.map do |line|
          PolicyOcr::Parser::ParsePolicyNumber.call(line:).policy_number
        end
        context.all_policy_numbers = all_policy_numbers
      end

      private

      def lines 
        raw_text
          .split(PolicyOcr::CARRIAGE_RETURN)
          .each_slice(PolicyOcr::LINE_HEIGHT)
          .to_a
      end

      def raw_text = @raw_text ||= context.raw_text
    end
  end
end
