# frozen_string_literal: true

# Common validation methods for Interactor classes
module Interactor
  module Validations
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
      return unless collection.size != expected_size

      call_validation_hook
      context.fail!(error: "#{key} must have exactly #{expected_size} elements")
    end

    # Validates that context values are present (not nil, empty, or blank)
    #
    # @param keys [Array<Symbol>] context keys that must be present
    def validate_presence_of(*keys)
      keys.each do |key|
        value = context.send(key)
        validate_single_key(key, value)
      end
    end

    # Validates using a custom block
    #
    # @param error_message [String] error message to display if validation fails
    # @param block [Proc] validation logic that should return true/false
    def validate(error_message, &block)
      return if block.call

      call_validation_hook
      context.fail!(error: error_message)
    end

    private

    # Validates a single key's presence and calls appropriate failure handling
    def validate_single_key(key, value)
      error_message = presence_error_message(key, value)
      return unless error_message

      call_validation_hook
      context.fail!(error: error_message)
    end

    # Returns appropriate error message for presence validation or nil if valid
    def presence_error_message(key, value)
      return "#{key} is required" if value.nil?
      return "#{key} cannot be empty" if value.respond_to?(:empty?) && value.empty?
      return "#{key} cannot be blank" if value.respond_to?(:strip) && value.strip.empty?

      nil
    end

    # Calls validation failed hook if it exists
    def call_validation_hook
      on_validation_failed if respond_to?(:on_validation_failed, true)
    end
  end
end
