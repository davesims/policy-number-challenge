require "spec_helper"

RSpec.describe Interactor::Validations do
  before { $hook_called = false }
  
  let(:test_class_with_hook) do
    Class.new do
      include Interactor
      include Interactor::Validations
      
      on_validation_failed do
        $hook_called = true
      end
      
      def call
        # Validation happens in before block
      end
    end
  end

  describe "#validate_presence_of" do
    let(:test_class) do
      Class.new(test_class_with_hook) do
        before do
          validate_presence_of(:test_key)
        end
      end
    end

    context "when validation passes" do
      it "does not call on_validation_failed hook" do
        result = test_class.call(test_key: "valid_value")
        expect(result).to be_success
        expect($hook_called).to be false
      end
    end

    context "when value is nil" do
      it "calls on_validation_failed hook before failing" do
        result = test_class.call(test_key: nil)
        expect(result).to be_failure
        expect($hook_called).to be true
        expect(result.error).to eq("test_key is required")
      end
    end

    context "when value is empty" do
      it "calls on_validation_failed hook before failing" do
        result = test_class.call(test_key: "")
        expect(result).to be_failure
        expect($hook_called).to be true
        expect(result.error).to eq("test_key cannot be empty")
      end
    end

    context "when value is blank" do
      it "calls on_validation_failed hook before failing" do
        result = test_class.call(test_key: "   ")
        expect(result).to be_failure
        expect($hook_called).to be true
        expect(result.error).to eq("test_key cannot be blank")
      end
    end
  end

  describe "#validate_size" do
    let(:test_class) do
      Class.new(test_class_with_hook) do
        before do
          validate_size(:test_array, 3)
        end
      end
    end
    
    context "when validation passes" do
      it "does not call on_validation_failed hook" do
        result = test_class.call(test_array: [1, 2, 3])
        expect(result).to be_success
        expect($hook_called).to be false
      end
    end

    context "when size is incorrect" do
      it "calls on_validation_failed hook before failing" do
        result = test_class.call(test_array: [1, 2])
        expect(result).to be_failure
        expect($hook_called).to be true
        expect(result.error).to eq("test_array must have exactly 3 elements")
      end
    end
  end

  describe "#validate" do
    context "when validation passes" do
      let(:test_class) do
        Class.new(test_class_with_hook) do
          before do
            validate("should not fail") { true }
          end
        end
      end

      it "does not call on_validation_failed hook" do
        result = test_class.call
        expect(result).to be_success
        expect($hook_called).to be false
      end
    end

    context "when validation fails" do
      let(:test_class) do
        Class.new(test_class_with_hook) do
          before do
            validate("custom error") { false }
          end
        end
      end

      it "calls on_validation_failed hook before failing" do
        result = test_class.call
        expect(result).to be_failure
        expect($hook_called).to be true
        expect(result.error).to eq("custom error")
      end
    end
  end

  describe "without on_validation_failed hook" do
    let(:test_class_without_hook) do
      Class.new do
        include Interactor
        include Interactor::Validations
        
        before do
          validate_presence_of(:test_key)
        end
        
        def call
          # Validation happens in before block
        end
      end
    end

    it "works normally without the hook" do
      result = test_class_without_hook.call(test_key: nil)
      expect(result).to be_failure
      expect(result.error).to eq("test_key is required")
    end
  end
end