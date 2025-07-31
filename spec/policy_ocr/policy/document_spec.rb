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

  describe "statistics methods" do
    let(:policy_numbers) { [valid_number, checksum_error_number, invalid_number] }
    let(:document) { described_class.new(policy_numbers) }

    describe "#total_count" do
      it "returns the total number of policy numbers" do
        expect(document.total_count).to eq(3)
      end
    end

    describe "#valid_count" do
      it "returns count of valid policy numbers" do
        expect(document.valid_count).to eq(1)
      end
    end

    describe "#err_count" do
      it "returns count of policy numbers with checksum errors" do
        expect(document.err_count).to eq(1)
      end
    end

    describe "#ill_count" do
      it "returns count of policy numbers with invalid digits" do
        expect(document.ill_count).to eq(1)
      end
    end
  end

  describe "statistics methods with empty document" do
    let(:empty_document) { described_class.new([]) }

    it "has zero total count" do
      expect(empty_document.total_count).to eq(0)
    end

    it "has zero valid count" do
      expect(empty_document.valid_count).to eq(0)
    end

    it "has zero error count" do
      expect(empty_document.err_count).to eq(0)
    end

    it "has zero invalid count" do
      expect(empty_document.ill_count).to eq(0)
    end
  end

  describe "statistics methods with all valid numbers" do
    let(:all_valid_document) { described_class.new([valid_number, valid_number]) }

    it "has correct total count" do
      expect(all_valid_document.total_count).to eq(2)
    end

    it "has correct valid count" do
      expect(all_valid_document.valid_count).to eq(2)
    end

    it "has zero error count" do
      expect(all_valid_document.err_count).to eq(0)
    end

    it "has zero invalid count" do
      expect(all_valid_document.ill_count).to eq(0)
    end
  end
end
