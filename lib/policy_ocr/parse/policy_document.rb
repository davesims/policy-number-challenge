# frozen_string_literal: true

module PolicyOcr
  module Parse
    class PolicyDocument
      include Interactor

      def call
        raw_text = File.read(context.file_path)
        result = PolicyOcr::Parse::PolicyDocumentLine.call(raw_text:)
        result.all_digits.each do |digital_int|
          puts digital_int.map(&:to_i).join(", ")
        end
      rescue StandardError => e
        context.fail!(error: e.message)
      end
    end
  end
end
