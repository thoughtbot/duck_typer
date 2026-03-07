# frozen_string_literal: true

require_relative "../duck_typer"

module DuckTyper
  module Minitest
    def assert_interfaces_match(objects, type: :instance_methods, methods: nil)
      checker = BulkInterfaceChecker
        .new(objects, type:, partial_interface_methods: methods)

      checker.call do |_, _, result|
        assert result.match?, result.failure_message
      end
    end
  end
end
