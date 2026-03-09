# frozen_string_literal: true

module DuckTyper
  # Factory for parameter normalization. Use ParamsNormalizer.for(strict:)
  # to get the right normalizer for the given comparison mode.
  module ParamsNormalizer # :nodoc:
    def self.for(strict:)
      strict ? StrictParamsNormalizer : DefaultParamsNormalizer
    end

    # Normalizes method parameters for default interface comparison.
    # Sorts keywords alphabetically and replaces positional argument
    # names with sequential placeholders.
    module DefaultParamsNormalizer # :nodoc:
      def self.call(params)
        KeywordNormalizer.call(params).then { |p| SequentialNormalizer.call(p) }
      end
    end

    # Normalizes method parameters for strict interface comparison,
    # where positional argument names are significant. Sorts keywords
    # alphabetically but preserves positional argument names.
    module StrictParamsNormalizer # :nodoc:
      def self.call(params)
        KeywordNormalizer.call(params)
      end
    end

    # Sorts keyword argument parameters alphabetically, making keyword
    # order irrelevant for interface comparison.
    module KeywordNormalizer # :nodoc:
      KEYWORD_TYPES = %i[key keyreq].freeze

      def self.call(params)
        keywords, sequentials = params.partition { |type, _| KEYWORD_TYPES.include?(type) }

        sequentials + keywords.sort_by { |_, name| name }
      end
    end

    # Replaces positional parameter names with sequential placeholders
    # (a, b, c, ...), focusing comparison on structure rather than naming.
    module SequentialNormalizer # :nodoc:
      SEQUENTIAL_TYPES = %i[req opt rest keyrest block].freeze

      class << self
        def call(params)
          sequential_name = ("a".."z").to_enum

          params.map do |type, name|
            if SEQUENTIAL_TYPES.include?(type)
              name = next_sequential_param(sequential_name)
            end

            [type, name]
          end
        end

        private

        def next_sequential_param(enumerator)
          enumerator.next.to_sym
        rescue StopIteration
          raise TooManyParametersError, "too many positional parameters, maximum supported is 26"
        end
      end
    end

    # A no-op params processor that returns params unchanged. Used when
    # interface comparison should preserve original parameter names rather
    # than normalizing them.
    module NullParamsNormalizer # :nodoc:
      def self.call(params)
        params
      end
    end
  end
end
