require 'spec_helper'

RSpec.describe PolicyOcr do
  describe '.call' do
    let(:context) { build(:policy_ocr_context) }
    
    context 'when file exists' do
      it 'successfully reads and processes the file' do
        result = PolicyOcr.call(context)
        
        expect(result).to be_success
      end
      
      it 'calls ReadLines with raw text' do
        expect(PolicyOcr::ReadLines).to receive(:call).with(raw_text: anything).and_call_original
        
        PolicyOcr.call(context)
      end
    end
    
    context 'when file does not exist' do
      let(:context) { build(:policy_ocr_context, file_path: 'nonexistent.txt') }
      
      it 'fails with error message' do
        result = PolicyOcr.call(context)
        
        expect(result).to be_failure
        expect(result.error).to include('No such file or directory')
      end
    end
  end
  
  describe 'constants' do
    it 'defines expected constants' do
      expect(PolicyOcr::DIGITS_PER_LINE).to eq(9)
      expect(PolicyOcr::DIGIT_WIDTH).to eq(3)
      expect(PolicyOcr::LINE_HEIGHT).to eq(4)
    end
  end
end