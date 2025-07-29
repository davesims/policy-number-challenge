# position names: d9 d8 d7 d6 d5 d4 d3 d2 d1
# checksum calculation: (d1+(2*d2)+(3*d3)+...+(9*d9)) mod 11 = 0
#
class PolicyOcr::ValidatePolicyNumberChecksum
  include Interactor
  include Interactor::Validations

  before do
    validate_presence_of(:policy_number)
    validate("policy number contains invalid digits") do
      context.policy_number.to_a.none?(&:nil?)
    end
  end

  def call
    dot_product = sequence.zip(policy_number_digits).map { |s, d| s * d }.sum
    checksum = dot_product % 11
    context.fail! unless checksum == 0
  end

  private

  def policy_number_digits = context.policy_number.to_a.reverse
  def sequence = (1..9).to_a
end
