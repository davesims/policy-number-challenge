# frozen_string_literal: true

require "spec_helper"

RSpec.describe PolicyOcr::ValidatePolicyNumberChecksum do
  subject(:result) { described_class.call(policy_number: policy_number) }

  let(:valid_digital_ints) do
    # Create digital ints for number 711111111 (known valid checksum)
    [7, 1, 1, 1, 1, 1, 1, 1, 1].map { |d| PolicyOcr::DigitalInt.from_int(d) }
  end

  let(:invalid_checksum_digital_ints) do
    # Create digital ints for number 111111111 (invalid checksum)
    [1, 1, 1, 1, 1, 1, 1, 1, 1].map { |d| PolicyOcr::DigitalInt.from_int(d) }
  end

  let(:invalid_digits_digital_ints) do
    # Mix of valid and invalid digital ints
    [
      PolicyOcr::DigitalInt.from_int(1),
      PolicyOcr::DigitalInt::Invalid.new(pattern: "???"),
      PolicyOcr::DigitalInt.from_int(3)
    ] + Array.new(6) { PolicyOcr::DigitalInt.from_int(1) }
  end

  describe ".call" do
    context "with valid checksum" do
      let(:policy_number) { PolicyOcr::Policy::Number.new(valid_digital_ints) }

      it "returns success" do
        expect(result).to be_success
      end
    end

    context "with invalid checksum" do
      let(:policy_number) { PolicyOcr::Policy::Number.new(invalid_checksum_digital_ints) }

      it "returns failure" do
        expect(result).to be_failure
      end
    end

    context "with invalid digits" do
      let(:policy_number) { PolicyOcr::Policy::Number.new(invalid_digits_digital_ints) }

      it "returns failure due to validation" do
        expect(result).to be_failure
        expect(result.error).to eq("policy number contains invalid digits")
      end
    end

    context "with missing policy_number" do
      subject(:result) { described_class.call({}) }

      it "returns failure due to validation" do
        expect(result).to be_failure
        expect(result.error).to eq("policy_number is required")
      end
    end

    context "with nil policy_number" do
      subject(:result) { described_class.call(policy_number: nil) }

      it "returns failure due to validation" do
        expect(result).to be_failure
        expect(result.error).to eq("policy_number is required")
      end
    end
  end
end
