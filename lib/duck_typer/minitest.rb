require_relative "../duck_typer"

module DuckTyper
  module Minitest
    def assert_interface_matches(objects, type: :instance_methods, methods: nil)
      checker = BulkInterfaceChecker
        .new(objects, type:, partial_interface_methods: methods)

      checker.call do |_, _, result|
        assert result.match?, result.failure_message
      end
    end
  end
end
