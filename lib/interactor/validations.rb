# frozen_string_literal: true

# Common validation methods for Interactor classes
module Interactor::Validations
  
  def self.included(base)
    base.extend(ClassMethods)
  end
  
  module ClassMethods
    # A callback invoked whenever validation fails. 
    def on_validation_failed(&block)
      define_method(:on_validation_failed) do
        instance_exec(&block)
      end
      private :on_validation_failed
    end
  end

  # Validates that a context collection has the expected size
  #
  # @param key [Symbol] context key containing the collection
  # @param expected_size [Integer] expected collection size
  def validate_size(key, expected_size)
    collection = context.send(key)
    if collection.size != expected_size
      on_validation_failed if respond_to?(:on_validation_failed, true)
      context.fail!(error: "#{key} must have exactly #{expected_size} elements")
    end
  end

  # Validates that context values are present (not nil, empty, or blank)
  #
  # @param keys [Array<Symbol>] context keys that must be present
  def validate_presence_of(*keys)
    keys.each do |key|
      value = context.send(key)
      
      if value.nil?
        on_validation_failed if respond_to?(:on_validation_failed, true)
        context.fail!(error: "#{key} is required")
      elsif value.respond_to?(:empty?) && value.empty?
        on_validation_failed if respond_to?(:on_validation_failed, true)
        context.fail!(error: "#{key} cannot be empty")
      elsif value.respond_to?(:strip) && value.strip.empty?
        on_validation_failed if respond_to?(:on_validation_failed, true)
        context.fail!(error: "#{key} cannot be blank")
      end
    end
  end

  # Validates using a custom block
  #
  # @param error_message [String] error message to display if validation fails
  # @param block [Proc] validation logic that should return true/false
  def validate(error_message, &block)
    unless block.call
      on_validation_failed if respond_to?(:on_validation_failed, true)
      context.fail!(error: error_message)
    end
  end
end
