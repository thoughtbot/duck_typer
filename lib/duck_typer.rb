# frozen_string_literal: true

require_relative "duck_typer/version"
require_relative "duck_typer/interface_checker"
require_relative "duck_typer/bulk_interface_checker"

# DuckTyper enforces duck-typed interfaces in Ruby by comparing the public
# method signatures of classes, surfacing mismatches through your test suite.
module DuckTyper
  class MethodNotFoundError < StandardError; end
  class TooManyParametersError < StandardError; end
end
