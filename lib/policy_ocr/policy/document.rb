# frozen_string_literal: true

module PolicyOcr
  module Policy
    class Document
      attr_reader :policy_numbers

      def initialize(policy_numbers)
        @policy_numbers = policy_numbers
      end

      def to_s
        policy_numbers.map(&:to_s).join(PolicyOcr::CARRIAGE_RETURN)
      end
    end
  end
end
