# frozen_string_literal: true

require "spec_helper"

RSpec.describe PolicyOcr::Policy::Document do
  let(:valid_number) do
    digital_ints = [7, 1, 1, 1, 1, 1, 1, 1, 1].map { |d| PolicyOcr::DigitalInt.from_int(d) }
    PolicyOcr::Policy::Number.new(digital_ints)
  end

  let(:invalid_number) { PolicyOcr::Policy::Number::Invalid.new }

  let(:checksum_error_number) do
    invalid_digital_ints = [1, 1, 1, 1, 1, 1, 1, 1, 1].map { |d| PolicyOcr::DigitalInt.from_int(d) }
    PolicyOcr::Policy::Number.new(invalid_digital_ints)
  end

  describe "#initialize" do
    context "with valid policy numbers" do
      let(:policy_numbers) { [valid_number, invalid_number] }
      let(:document) { described_class.new(policy_numbers) }

      it "accepts an array of policy numbers" do
        expect(document.policy_numbers).to eq(policy_numbers)
      end
    end

    context "with an empty array" do
      let(:policy_numbers) { [] }
      let(:document) { described_class.new(policy_numbers) }

      it "accepts an empty array" do
        expect(document.policy_numbers).to eq([])
      end
    end
  end

  describe "#to_s" do
    context "with single policy number" do
      let(:policy_numbers) { [valid_number] }
      let(:document) { described_class.new(policy_numbers) }

      it "returns the policy number as string" do
        expect(document.to_s).to eq("711111111 ")
      end
    end

    context "with multiple policy numbers" do
      let(:policy_numbers) { [valid_number, checksum_error_number, invalid_number] }
      let(:document) { described_class.new(policy_numbers) }

      it "returns the policy numbers array" do
        expected_output = ["711111111 ", "111111111 ERR", "????????? ILL"].join("\n")
        expect(document.to_s).to eq(expected_output)
      end
    end

    context "with empty policy numbers" do
      let(:policy_numbers) { [] }
      let(:document) { described_class.new(policy_numbers) }

      it "returns empty string" do
        expect(document.to_s).to eq("")
      end
    end

    context "with mixed valid and invalid numbers" do
      let(:policy_numbers) { [invalid_number, valid_number] }
      let(:document) { described_class.new(policy_numbers) }

      it "preserves the order and formatting" do
        expected_output = ["????????? ILL", "711111111 "].join("\n")
        expect(document.to_s).to eq(expected_output)
      end
    end
  end

  describe "#policy_numbers" do
    let(:policy_numbers) { [valid_number, invalid_number] }
    let(:document) { described_class.new(policy_numbers) }

    it "returns an array" do
      expect(document.policy_numbers).to be_an(Array)
    end

    it "has correct size" do
      expect(document.policy_numbers.size).to eq(2)
    end

    it "contains policy number objects" do
      expect(document.policy_numbers.first).to be_a(PolicyOcr::Policy::Number)
    end
  end
end
