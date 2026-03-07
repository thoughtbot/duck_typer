# frozen_string_literal: true

module DuckTyper
  # A no-op params processor that returns params unchanged. Used when
  # interface comparison should preserve original parameter names rather
  # than normalizing them.
  class NullParamsNormalizer # :nodoc:
    def self.call(params)
      params
    end
  end
end
