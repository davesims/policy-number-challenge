# frozen_string_literal: true

require "spec_helper"

RSpec.describe PolicyOcr::DigitalInt do
  let(:pattern) { " _ | ||_|" }
  let(:digit) { described_class.from_pattern(pattern) }

  describe ".all_numbers" do
    it "returns all digit classes" do
      expected_classes = [
        PolicyOcr::DigitalInt::Zero,
        PolicyOcr::DigitalInt::One,
        PolicyOcr::DigitalInt::Two,
        PolicyOcr::DigitalInt::Three,
        PolicyOcr::DigitalInt::Four,
        PolicyOcr::DigitalInt::Five,
        PolicyOcr::DigitalInt::Six,
        PolicyOcr::DigitalInt::Seven,
        PolicyOcr::DigitalInt::Eight,
        PolicyOcr::DigitalInt::Nine
      ]

      expect(described_class.all_numbers).to eq(expected_classes)
    end
  end

  describe ".from_pattern" do
    it "returns correct digit instance for valid pattern" do
      expect(digit).to be_a(PolicyOcr::DigitalInt::Zero)
      expect(digit.to_i).to eq(0)
    end

    context "with an invalid pattern" do
      let(:pattern) { "xxx" }

      it "returns Invalid instance for invalid pattern" do
        expect(digit).to be_a(PolicyOcr::DigitalInt::Invalid)
      end
    end
  end
end
