# frozen_string_literal: true

module DuckTyper
  class InterfaceChecker
    # Normalizes method parameters to enable interface comparison. For
    # example, two methods may use different names for positional
    # arguments, but if the parameter types and order match, they should
    # be considered equivalent. This class replaces argument names with
    # sequential placeholders when appropriate, focusing the comparison on
    # parameter structure rather than naming.
    class ParamsNormalizer
      KEYWORD_TYPES = %i[key keyreq].freeze

      class << self
        def call(params)
          sequential_name = ("a".."z").to_enum

          sort_keyword_params(params).map do |type, name|
            if %i[req opt rest keyrest block].include?(type)
              name = next_sequential_param(sequential_name)
            end

            [type, name]
          end
        end

        private

        # Keyword argument order is irrelevant to a method's interface —
        # m(a:, b:) and m(b:, a:) are equivalent. Sort keyword params
        # alphabetically so comparison is order-independent.
        def sort_keyword_params(params)
          keywords, non_keywords = params.partition do |type, _|
            KEYWORD_TYPES.include?(type)
          end

          non_keywords + keywords.sort_by { |_, name| name }
        end

        def next_sequential_param(enumerator)
          enumerator.next
        rescue StopIteration
          raise TooManyParametersError, "too many positional parameters, maximum supported is 26"
        end
      end
    end
  end
end
