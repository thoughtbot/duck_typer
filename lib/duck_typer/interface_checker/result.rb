# frozen_string_literal: true

module DuckTyper
  class InterfaceChecker
    class Result
      attr_reader :left, :right

      def initialize(left:, right:, match:, diff_message:)
        @left = left
        @right = right
        @match = match
        @diff_message = diff_message
      end

      def match?
        @match.call
      end

      def failure_message
        return if match?

        <<~MSG
          Expected #{@left} and #{@right} to implement compatible \
          interfaces, but the following method signatures differ:

          #{@diff_message.call}
        MSG
      end
    end
  end
end
