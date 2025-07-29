# frozen_string_literal: true

# Common validation methods for Interactor classes
module InteractorValidations

  # Validates that a context collection has the expected size
  #
  # @param key [Symbol] context key containing the collection
  # @param expected_size [Integer] expected collection size
  def validate_size(key, expected_size)
    collection = context.send(key)
    context.fail!(error: "#{key} must have exactly #{expected_size} elements") if collection.size != expected_size
  end

  # Validates that context values are present (not nil, empty, or blank)
  #
  # @param keys [Array<Symbol>] context keys that must be present
  def validate_presence_of(*keys)
    keys.each do |key|
      value = context.send(key)
      
      if value.nil?
        context.fail!(error: "#{key} is required")
      elsif value.respond_to?(:empty?) && value.empty?
        context.fail!(error: "#{key} cannot be empty")
      elsif value.respond_to?(:strip) && value.strip.empty?
        context.fail!(error: "#{key} cannot be blank")
      end
    end
  end

  # Validates using a custom block
  #
  # @param error_message [String] error message to display if validation fails
  # @param block [Proc] validation logic that should return true/false
  def validate(error_message, &block)
    context.fail!(error: error_message) unless block.call
  end
end
