# frozen_string_literal: true

module PolicyOcr
  module Parser
    class ParsePolicyDocumentText
      include Interactor
      include Interactor::Validations

      before do
        validate_presence_of(:raw_text)
      end

      # Parses raw text of a policy document into policy numbers.
      #
      # Takes raw text and splits it on carriage returns, slicing the lines into 
      # groups of LINE_HEIGHT (4 lines) to represent each policy number, then sends 
      # each group of lines to ParsePolicyNumberLine to parse the policy number.
      #
      # @param context [Interactor::Context] must contain raw_text
      # @return [Interactor::Context] result with policy_numbers array set
      def call
        PolicyOcr.logger_for(self).info("Parsing policy document text...")
        policy_numbers = number_lines.map.with_index do |number_line, index|
          result = PolicyOcr::Parser::ParsePolicyNumberLine.call(number_line:, index:)
          unless result.success?
            context.parser_errors ||= []
            context.parser_errors << result.error
          end
          result.policy_number
        end
        context.policy_numbers = policy_numbers
      end

      private

      # number_lines is the entire document represented as an N x LINE_HEIGHT
      # array, where N is the number of policy numbers in the document, and 
      # LINE_HEIGHT is the number of lines (4) per policy number, i.e., the height
      # of a digit pattern in chars.
      def number_lines 
        raw_text
          .split(PolicyOcr::CARRIAGE_RETURN)
          .each_slice(PolicyOcr::LINE_HEIGHT)
          .to_a
      end

      def raw_text = context.raw_text
    end
  end
end
