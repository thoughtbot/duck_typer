# frozen_string_literal: true

module DuckTyper
  # Normalizes method parameters to enable interface comparison.
  # Keyword argument order is irrelevant — m(a:, b:) and m(b:, a:)
  # are equivalent — so keywords are sorted alphabetically. Positional
  # argument names are also replaced with sequential placeholders,
  # focusing the comparison on parameter structure rather than naming.
  class ParamsNormalizer # :nodoc:
    KEYWORD_TYPES = %i[key keyreq].freeze
    SEQUENTIAL_TYPES = %i[req opt rest keyrest block].freeze

    class << self
      def call(params)
        sort_keyword_params(params).then { |sorted| sequentialize_params(sorted) }
      end

      private

      def sort_keyword_params(params)
        keywords, sequentials = params.partition do |type, _|
          KEYWORD_TYPES.include?(type)
        end

        sequentials + keywords.sort_by { |_, name| name }
      end

      def sequentialize_params(params)
        sequential_name = ("a".."z").to_enum

        params.map do |type, name|
          if SEQUENTIAL_TYPES.include?(type)
            name = next_sequential_param(sequential_name)
          end

          [type, name]
        end
      end

      def next_sequential_param(enumerator)
        enumerator.next.to_sym
      rescue StopIteration
        raise TooManyParametersError, "too many positional parameters, maximum supported is 26"
      end
    end
  end
end
