require 'spec_helper'

RSpec.describe PolicyOcr::DigitalInt::Two do
  describe '.pattern' do
    it 'returns correct pattern' do
      expected = " _  _||_    "
      expect(described_class.pattern).to eq(expected)
    end
  end
  
  describe '#to_i' do
    it 'returns 2' do
      expect(described_class.new.to_i).to eq(2)
    end
  end
  
  describe '#pattern' do
    it 'returns the same as class pattern' do
      instance = described_class.new
      expect(instance.pattern).to eq(described_class.pattern)
    end
  end
end