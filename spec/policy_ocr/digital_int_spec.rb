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
      expect(digit.int_value).to eq(0)
    end
    
    it 'returns nil for invalid pattern' do
      invalid_pattern = "xxx"
      digit = described_class.from_pattern(invalid_pattern)
      
      expect(digit).to be_nil
    end
  end
  
  describe '.print_pattern' do
    it 'raises NotImplementedError for base class' do
      expect { described_class.print_pattern }.to raise_error(NotImplementedError)
    end
  end
  
  describe '#to_i' do
    it 'raises NotImplementedError for base class' do
      instance = described_class.new
      expect { instance.to_i }.to raise_error(NotImplementedError)
    end
  end
  
  describe '#print_pattern' do
    it 'delegates to class method' do
      digit = PolicyOcr::DigitalInt::Zero.new
      expect(PolicyOcr::DigitalInt::Zero).to receive(:print_pattern)
      
      digit.print_pattern
    end
  end
end