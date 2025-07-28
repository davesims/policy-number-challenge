require 'spec_helper'

RSpec.describe PolicyOcr::DigitalInt do
  describe '.all_numbers' do
    it 'returns all digit classes' do
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
  
  describe '.from_pattern' do
    it 'returns correct digit instance for valid pattern' do
      zero_pattern = " _ " + "| |" + "|_|" + "   "
      digit = described_class.from_pattern(zero_pattern)
      
      expect(digit).to be_a(PolicyOcr::DigitalInt::Zero)
      expect(digit.to_i).to eq(0)
    end
    
    it 'returns Invalid instance for invalid pattern' do
      invalid_pattern = "xxx"
      digit = described_class.from_pattern(invalid_pattern)
      
      expect(digit).to be_a(PolicyOcr::DigitalInt::Invalid)
    end
  end
end