# frozen_string_literal: true

module DuckTyper
  class InterfaceChecker
    class Result
      attr_reader :left, :right

      def initialize(left:, right:, match:, diff_message:, name: nil)
        @left = left
        @right = right
        @match = match
        @diff_message = diff_message
        @name = name
      end

      def match?
        @match.call
      end

      def failure_message
        return if match?

        interface_label = @name ? %("#{@name}" interfaces) : "interfaces"

        <<~MSG
          Expected #{@left} and #{@right} to implement compatible \
          #{interface_label}, but the following method signatures differ:

          #{@diff_message.call}
        MSG
      end
    end
  end
end
