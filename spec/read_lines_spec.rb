require_relative '../lib/read_digit_lines.rb'
require_relative '../lib/digital_number.rb'

describe ReadDigitLines do
  let(:text) { File.read("./spec/fixtures/sample.txt") }

  subject { ReadDigitLines.call(text: text) }

  it "succeeds" do
    expect(subject).to be_success
    expect (subject.numbers).to be_a(Array)
    expect(subject.numbers[0]).to eq(PolicyOcr::DigitalInt::ZERO)
  end
end
