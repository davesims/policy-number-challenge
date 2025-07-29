# frozen_string_literal: true

module PolicyOcr
  module Parser
    # ParsePolicyDodcumentLines takes the raw text of a policy document
    # and splits it on carriage returns, slicing the lines into groups of 
    # LINE_HEIGHT (4 lines) to represent each policy number, then sends each
    # group of lines to ParsePolicyNumber to parse the policy number.
    #
    # It returns an array of Policy::Number objects on the result as 
    # all_policy_numbers.
    class ParsePolicyDocumentText
      include Interactor
      include InteractorValidations

      before do
        validate_presence_of(:raw_text)
      end

      def call
        all_policy_numbers = number_lines.map do |number_line|
          PolicyOcr::Parser::ParsePolicyNumberLine.call(number_line:).policy_number
        end
        context.all_policy_numbers = all_policy_numbers
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
