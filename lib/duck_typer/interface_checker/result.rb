module DuckTyper
  class InterfaceChecker
    class Result
      attr_reader :left, :right

      def initialize(left:, right:, match:, method_signatures:)
        @left = left
        @right = right
        @match = match
        @method_signatures = method_signatures
      end

      def match?
        @match.call
      end

      def failure_message
        <<~MSG
          Expected #{@left} and #{@right} to have compatible method \
          signatures, but the following signatures do not match:

          #{method_signatures}
        MSG
      end

      private

      def method_signatures
        @method_signatures.call
      end
    end
  end
end
