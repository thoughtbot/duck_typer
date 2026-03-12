# frozen_string_literal: true

module DuckTyper
  class InterfaceChecker
    class Result
      attr_reader :left, :right

      def initialize(left:, right:, match:, diff_message:, name:, strict:)
        @left = left
        @right = right
        @match = match
        @diff_message = diff_message
        @name = name
        @strict = strict
      end

      def match?
        @match.call
      end

      def failure_message
        return if match?

        <<~MSG
          Expected #{@left} and #{@right} to implement compatible \
          #{interface_label}, but the following method signatures differ:#{strict_note}

          #{@diff_message.call}
        MSG
      end

      private

      def interface_label
        @name ? %("#{@name}" interfaces) : "interfaces"
      end

      def strict_note
        @strict ? " (strict mode: positional argument names must match)" : ""
      end
    end
  end
end
