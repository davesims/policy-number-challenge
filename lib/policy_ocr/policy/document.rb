# frozen_string_literal: true

module PolicyOcr
  module Policy
    class Document
      attr_reader :policy_numbers

      def initialize(policy_numbers)
        @policy_numbers = policy_numbers
      end

      def to_s
        return "" if policy_numbers.empty?

        # Join policy numbers with carriage return and add a trailing carriage return (POSIX standard)
        policy_numbers.map(&:to_s).join(PolicyOcr::CARRIAGE_RETURN) + PolicyOcr::CARRIAGE_RETURN
      end

      # Statistics methods
      def total_count
        policy_numbers.size
      end

      def valid_count
        policy_numbers.count(&:valid?)
      end

      def err_count
        policy_numbers.count(&:checksum_error?)
      end

      def ill_count
        policy_numbers.count(&:ill?)
      end

      def unparseable_count
        policy_numbers.count(&:unparseable?)
      end
    end
  end
end
