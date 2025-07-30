# frozen_string_literal: true

class PolicyOcr::ValidatePolicyNumberChecksum
  include Interactor
  include Interactor::Validations

  before do
    validate_presence_of(:policy_number)
    validate("policy number contains invalid digits") do
      context.policy_number.to_a.none?(&:nil?)
    end
  end

  # Validates the checksum of a policy number.
  #
  # The checksum is calculated using the formula:
  # (d1 + (2 * d2) + (3 * d3) + ... + (9 * d9)) % 11 == 0
  # where d1 to d9 are the digits of the policy number in reverse order.
  #
  # example use: 
  #   policy_number = "123456789"
  #   PolicyOcr::ValidatePolicyNumberChecksum.call(policy_number: policy_number).success? # => false
  #
  # @param [Context] context The context containing the policy number to validate.
  # @return [void] fails the context if the checksum is invalid.
  def call
    dot_product = sequence.zip(policy_number_digits).map { |s, d| s * d }.sum
    checksum = dot_product % 11
    context.fail! unless checksum == 0
  end

  private

  def policy_number_digits = context.policy_number.to_a.reverse
  def sequence = (1..policy_number_digits.size).to_a
end
