module PolicyOcr
  module DigitalInt
    class Base
      attr_reader :int_value
      alias_method :to_i, :int_value

      def pattern
        self.class.pattern
      end

      def to_s
        int_value.to_s
      end

      def valid?
        true
      end
    end
  end
end
