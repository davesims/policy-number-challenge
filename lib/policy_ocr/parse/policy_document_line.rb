# frozen_string_literal: true

module PolicyOcr
  module Parse
    class PolicyDocumentLine
      include Interactor

      def call
        all_digits = lines.map do |line|
          PolicyOcr::Parse::PolicyNumber.call(line:).digits
        end
        context.all_digits = all_digits
      end

      private

      def lines 
        raw_text
          .split(PolicyOcr::CARRIAGE_RETURN)
          .each_slice(PolicyOcr::LINE_HEIGHT)
          .to_a
      end

      def raw_text = @raw_text ||= context.raw_text
    end
  end
end
