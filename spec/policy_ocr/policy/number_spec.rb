# frozen_string_literal: true

require "spec_helper"

RSpec.describe PolicyOcr::Policy::Number do
  let(:valid_digital_ints) do
    # Create digital ints for number 711111111 (known valid)
    [7, 1, 1, 1, 1, 1, 1, 1, 1].map { |d| PolicyOcr::DigitalInt.from_int(d) }
  end

  let(:invalid_digital_ints) do
    # Mix of valid and invalid digital ints
    [
      PolicyOcr::DigitalInt.from_int(1),
      PolicyOcr::DigitalInt::Invalid.new(pattern: "???"),
      PolicyOcr::DigitalInt.from_int(3)
    ] + Array.new(6) { PolicyOcr::DigitalInt.from_int(1) }
  end

  let(:checksum_invalid_digital_ints) do
    # Create digital ints for number 111111111 (invalid checksum)
    [1, 1, 1, 1, 1, 1, 1, 1, 1].map { |d| PolicyOcr::DigitalInt.from_int(d) }
  end

  describe "#initialize" do
    it "accepts an array of digital ints" do
      number = described_class.new(valid_digital_ints)

      expect(number.digital_ints).to eq(valid_digital_ints)
    end
  end

  describe "#all_digits_valid?" do
    context "when all digital ints are valid" do
      it "returns true" do
        number = described_class.new(valid_digital_ints)

        expect(number.all_digits_valid?).to be true
      end
    end

    context "when some digital ints are invalid" do
      it "returns false" do
        number = described_class.new(invalid_digital_ints)

        expect(number.all_digits_valid?).to be false
      end
    end

    context "when digital ints array is empty" do
      it "returns false" do
        number = described_class.new([])

        expect(number.all_digits_valid?).to be false
      end
    end
  end

  describe "#checksum_valid?" do
    it "delegates to ValidatePolicyNumberChecksum" do
      number = described_class.new(valid_digital_ints)
      expect(PolicyOcr::ValidatePolicyNumberChecksum).to receive(:call).with(policy_number: number).and_call_original
      number.checksum_valid?
    end
  end

  describe "#to_s" do
    context "with valid digits and valid checksum" do
      it "returns number with no error message" do
        number = described_class.new(valid_digital_ints)

        expect(number.to_s).to eq("711111111 ")
      end
    end

    context "with invalid digits" do
      it "returns number with ILL message" do
        number = described_class.new(invalid_digital_ints)

        expect(number.to_s).to eq("1?3111111 ILL")
      end
    end

    context "with valid digits but invalid checksum" do
      it "returns number with ERR message" do
        number = described_class.new(checksum_invalid_digital_ints)

        expect(number.to_s).to eq("111111111 ERR")
      end
    end
  end

  describe "#to_a" do
    it "returns array of integer values" do
      number = described_class.new(valid_digital_ints)

      expect(number.to_a).to eq([7, 1, 1, 1, 1, 1, 1, 1, 1])
    end

    context "with invalid digits" do
      it "returns array with nil for invalid digits" do
        number = described_class.new(invalid_digital_ints)

        expect(number.to_a).to eq([1, nil, 3, 1, 1, 1, 1, 1, 1])
      end
    end
  end

  describe "#message" do
    context "with valid digits and valid checksum" do
      it "returns empty string" do
        number = described_class.new(valid_digital_ints)

        expect(number.message).to eq("")
      end
    end

    context "with invalid digits" do
      it "returns ILL message" do
        number = described_class.new(invalid_digital_ints)

        expect(number.message).to eq("ILL")
      end
    end

    context "with valid digits but invalid checksum" do
      it "returns ERR message" do
        number = described_class.new(checksum_invalid_digital_ints)

        expect(number.message).to eq("ERR")
      end
    end
  end

  describe "#valid?" do
    context "with valid digits and valid checksum" do
      it "returns true" do
        number = described_class.new(valid_digital_ints)
        expect(number.valid?).to be true
      end
    end

    context "with invalid digits" do
      it "returns false" do
        number = described_class.new(invalid_digital_ints) 
        expect(number.valid?).to be false
      end
    end

    context "with valid digits but invalid checksum" do
      it "returns false" do
        number = described_class.new(checksum_invalid_digital_ints)
        expect(number.valid?).to be false
      end
    end
  end

  describe "#has_checksum_error?" do
    context "with valid digits and valid checksum" do
      it "returns false" do
        number = described_class.new(valid_digital_ints)
        expect(number.has_checksum_error?).to be false
      end
    end

    context "with invalid digits" do
      it "returns false" do
        number = described_class.new(invalid_digital_ints)
        expect(number.has_checksum_error?).to be false
      end
    end

    context "with valid digits but invalid checksum" do
      it "returns true" do
        number = described_class.new(checksum_invalid_digital_ints)
        expect(number.has_checksum_error?).to be true
      end
    end
  end

  describe "#has_invalid_digits?" do
    context "with valid digits and valid checksum" do
      it "returns false" do
        number = described_class.new(valid_digital_ints)
        expect(number.has_invalid_digits?).to be false
      end
    end

    context "with invalid digits" do
      it "returns true" do
        number = described_class.new(invalid_digital_ints)
        expect(number.has_invalid_digits?).to be true
      end
    end

    context "with valid digits but invalid checksum" do
      it "returns false" do
        number = described_class.new(checksum_invalid_digital_ints)
        expect(number.has_invalid_digits?).to be false
      end
    end
  end

  describe PolicyOcr::Policy::Number::Invalid do
    let(:invalid_number) { described_class.new }

    describe "#initialize" do
      it "creates invalid digital ints" do
        expect(invalid_number.digital_ints.size).to eq(9)
        expect(invalid_number.digital_ints.all? { |d| d.is_a?(PolicyOcr::DigitalInt::Invalid) }).to be true
      end

      it "uses --- pattern for invalid digits" do
        pattern = invalid_number.digital_ints.first.pattern

        expect(pattern).to eq("---")
      end
    end

    describe "#all_digits_valid?" do
      it "returns false" do
        expect(invalid_number.all_digits_valid?).to be false
      end
    end

    describe "#checksum_valid?" do
      it "returns false" do
        expect(invalid_number.checksum_valid?).to be false
      end
    end

    describe "#to_s" do
      it "returns question marks with ILL message" do
        expect(invalid_number.to_s).to eq("????????? ILL")
      end
    end

    describe "#to_a" do
      it "returns array of nils" do
        expect(invalid_number.to_a).to eq([nil, nil, nil, nil, nil, nil, nil, nil, nil])
      end
    end

    describe "#message" do
      it "returns ILL message" do
        expect(invalid_number.message).to eq("ILL")
      end
    end
  end
end
