# frozen_string_literal: true

require_relative "../duck_typer"

module DuckTyper
  module Minitest
    def assert_interfaces_match(objects = nil, namespace: nil, type: :instance_methods, methods: nil, strict: false, name: nil)
      checker = BulkInterfaceChecker
        .new(objects, namespace:, type:, partial_interface_methods: methods, strict:, name:)

      checker.call do |result|
        assert result.match?, result.failure_message
      end
    end

    alias_method :assert_duck_types_match, :assert_interfaces_match
  end
end
