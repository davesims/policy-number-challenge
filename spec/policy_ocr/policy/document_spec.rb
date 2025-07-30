require "spec_helper"

RSpec.describe PolicyOcr::Policy::Document do
  let(:digital_ints) {[7,1,1,1,1,1,1,1,1].map { |d| PolicyOcr::DigitalInt.from_int(d) }}
  let(:valid_number) { PolicyOcr::Policy::Number.new(digital_ints) }
  let(:invalid_number) { PolicyOcr::Policy::Number::Invalid.new }

  let(:invalid_digital_ints) {[1,1,1,1,1,1,1,1,1].map { |d| PolicyOcr::DigitalInt.from_int(d) }}
  let(:checksum_error_number) { PolicyOcr::Policy::Number.new(invalid_digital_ints) }

  let(:policy_numbers) {[valid_number, invalid_number]}
  let(:document) { PolicyOcr::Policy::Document.new(policy_numbers) }

  describe "#initialize" do
    context "with valid policy numbers" do 
      it "accepts an array of policy numbers" do
        expect(document.policy_numbers).to eq(policy_numbers)
      end
    end

    context "with an empty array" do 
      let(:policy_numbers) { [] }
      it "accepts an empty array" do
        expect(document.policy_numbers).to eq([])
      end
    end
  end

  describe "#to_s" do
    context "with single policy number" do
      let(:policy_numbers) { [valid_number] }
      it "returns the policy number as string" do
        expect(document.to_s).to eq("711111111 ")
      end
    end

    context "with multiple policy numbers" do
      let(:policy_numbers) { [valid_number, checksum_error_number, invalid_number] }
      let(:expected_output) { [ "711111111 ", "111111111 ERR", "????????? ILL" ].join("\n") }

      it "returns the policy numbers array" do
        expect(document.to_s).to eq(expected_output)
      end
    end

    context "with empty policy numbers" do
      let(:policy_numbers) { [] }
      it "returns empty string" do
        expect(document.to_s).to eq("")
      end
    end

    context "with mixed valid and invalid numbers" do
      let(:policy_numbers) { [invalid_number, valid_number] }
      let(:expected_output) { [ "????????? ILL", "711111111 " ].join("\n") }

      it "preserves the order and formatting" do
        expect(document.to_s).to eq(expected_output)
      end
    end
  end

  describe "#policy_numbers" do
    let(:policy_numbers) { [valid_number, invalid_number] }
    it "is readable" do
      expect(document.policy_numbers).to be_an(Array)
      expect(document.policy_numbers.size).to eq(2)
      expect(document.policy_numbers.first).to be_a(PolicyOcr::Policy::Number)
    end
  end
end
