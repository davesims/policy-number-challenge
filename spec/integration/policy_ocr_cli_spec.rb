require "spec_helper"
require "tempfile"

RSpec.describe "PolicyOcrCLI Integration - parse command" do
  let(:file_path) { "spec/fixtures/sample.txt" }
  let(:exit_code) { $?.exitstatus }
  let(:line_matcher) { /^\d{9} $|^\d{9} ERR$|^\d*\?+\d* ILL$|\?{9} ILL$|^123456789$/ }

  subject { %x{ policy_ocr parse #{file_path} } }

  def run_parse_command(file_path)
    output = %x{ policy_ocr parse #{file_path} }

    {
      output: output,
      exit_code: $?.exitstatus
    }
  end

  describe "parse" do
    context "with valid policy numbers" do
      let(:lines) { subject.strip.split("\n") }

      it "outputs valid numbers with trailing space" do
        expect(subject).to include("000000000 ")
        expect(subject).to include("111111111 ")
        lines.each do |line|
          expect(line).to match(line_matcher)
        end
        expect(lines.size).to eq(11)
        expect(exit_code).to eq(0)
      end
    end
    
    context "with invalid digits" do
      let(:file_path) { "spec/fixtures/invalid_digits.txt" }

      it "outputs question marks with ILL suffix" do
        expect(subject).to include("ILL")
        expect(subject).to include("?")
        expect(exit_code).to eq(0)
      end
    end
    
    context "with checksum errors" do
      let(:file_path) { "spec/fixtures/checksum_errors.txt" }
      it "outputs numbers with ERR suffix" do
        expect(subject).to include("ERR")
        expect(exit_code).to eq(0)
      end
    end
    
    context "with mixed scenarios" do
      let(:file_path) { "spec/fixtures/mixed_policy_numbers.txt" }
      it "handles combination of valid, invalid digits, and checksum errors" do
        expect(subject).to include(" ")    # Valid numbers
        expect(subject).to include("ERR")  # Checksum errors  
        expect(subject).to include("ILL")  # Invalid digits
        expect(exit_code).to eq(0)
      end
    end
  end
  
  describe "error handling scenarios" do
    context "when file does not exist" do
      let(:file_path) { "nonexistent_file.txt" }

      it "displays error message and exits with code 1" do
        expect(subject).to include("Error: File 'nonexistent_file.txt' not found")
        expect(exit_code).to eq(1)
      end
    end
    
    context "when file exists but is empty" do
      let(:file_path) { "spec/fixtures/empty.txt" }
      it "handles empty files gracefully" do
        expect(subject).to include("Error: Failed to parse policy document: raw_text cannot be empty")
      end
    end
    
    context "when file has malformed content" do
      let(:file_path) { "spec/fixtures/malformed_content.txt" }
      it "handles files with incorrect line counts" do
        expect(subject).to include("Malformed number line")
        expect(subject).to include("Malformed number line at 3: element size differs (7 should be 10)")
        expect(subject).to include("Malformed number line at 2: element size differs (0 should be 9)")
      end
    end
  end
end
