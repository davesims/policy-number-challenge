require "spec_helper"

RSpec.describe PolicyOcr::Policy::Document do
  let(:valid_number) do
    digital_ints = [7,1,1,1,1,1,1,1,1].map { |d| PolicyOcr::DigitalInt.from_int(d) }
    PolicyOcr::Policy::Number.new(digital_ints)
  end

  let(:invalid_number) do
    PolicyOcr::Policy::Number::Invalid.new
  end

  let(:checksum_error_number) do
    digital_ints = [1,1,1,1,1,1,1,1,1].map { |d| PolicyOcr::DigitalInt.from_int(d) }
    PolicyOcr::Policy::Number.new(digital_ints)
  end

  describe "#initialize" do
    it "accepts an array of policy numbers" do
      policy_numbers = [valid_number, invalid_number]
      document = PolicyOcr::Policy::Document.new(policy_numbers)
      
      expect(document.policy_numbers).to eq(policy_numbers)
    end

    it "accepts an empty array" do
      document = PolicyOcr::Policy::Document.new([])
      
      expect(document.policy_numbers).to eq([])
    end
  end

  describe "#to_s" do
    context "with single policy number" do
      it "returns the policy number as string" do
        document = PolicyOcr::Policy::Document.new([valid_number])
        
        expect(document.to_s).to eq("711111111 ")
      end
    end

    context "with multiple policy numbers" do
      it "returns policy numbers separated by carriage returns" do
        policy_numbers = [valid_number, checksum_error_number, invalid_number]
        document = PolicyOcr::Policy::Document.new(policy_numbers)
        
        expected_output = [
          "711111111 ",
          "111111111 ERR", 
          "????????? ILL"
        ].join("\n")
        
        expect(document.to_s).to eq(expected_output)
      end
    end

    context "with empty policy numbers" do
      it "returns empty string" do
        document = PolicyOcr::Policy::Document.new([])
        
        expect(document.to_s).to eq("")
      end
    end

    context "with mixed valid and invalid numbers" do
      it "preserves the order and formatting" do
        policy_numbers = [invalid_number, valid_number]
        document = PolicyOcr::Policy::Document.new(policy_numbers)
        
        expected_output = [
          "????????? ILL",
          "711111111 "
        ].join("\n")
        
        expect(document.to_s).to eq(expected_output)
      end
    end
  end

  describe "#policy_numbers" do
    it "is readable" do
      policy_numbers = [valid_number, invalid_number]
      document = PolicyOcr::Policy::Document.new(policy_numbers)
      
      expect(document.policy_numbers).to be_an(Array)
      expect(document.policy_numbers.size).to eq(2)
      expect(document.policy_numbers.first).to be_a(PolicyOcr::Policy::Number)
    end
  end
end