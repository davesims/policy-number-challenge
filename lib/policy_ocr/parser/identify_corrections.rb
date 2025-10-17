# frozen_string_literal: true

module PolicyOcr
  module Parser
    class IdentifyCorrections
      include Interactor
      include Interactor::Validations

      def call
        corrections = [].tap do |corrs|
          policy_number.digital_ints.each_with_index do |digit, index|
            digit.adjacent_digits.each do |adj_digit|
              new_digits = policy_number.digital_ints.dup
              new_digits[index] = adj_digit
              new_policy_number = PolicyOcr::Policy::Number.new(new_digits)
              corrs << new_policy_number if new_policy_number.valid? && !corrs.include?(new_policy_number)
            end
          end
        end
        context.corrections = corrections
      end
    end

    private

    def policy_number = context.policy_number
  end
end
