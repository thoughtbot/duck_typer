# frozen_string_literal: true

require_relative "../duck_typer"

RSpec::Matchers.define :have_matching_interfaces do |type: :instance_methods, methods: nil|
  match do |objects|
    checker = DuckTyper::BulkInterfaceChecker
      .new(objects, type:, partial_interface_methods: methods)

    @failures = checker.call.reject(&:match?)
    @failures.empty?
  end

  failure_message do
    @failures.map(&:failure_message).join("\n")
  end
end

module DuckTyper
  module RSpec
    def self.define_shared_example(name = "an interface")
      ::RSpec.shared_examples name do |*objects, type: :instance_methods, methods: nil|
        objects = objects.first
        # We intentionally avoid reusing the have_matching_interfaces matcher
        # here. Since this shared example is defined in gem code, RSpec filters
        # it from its backtrace, causing the Failure/Error: line to show an
        # internal RSpec constant instead of useful context.
        it "has compatible interfaces" do
          checker = DuckTyper::BulkInterfaceChecker
            .new(objects, type:, partial_interface_methods: methods)

          failures = checker.call.reject(&:match?)

          if failures.any?
            message = failures.map(&:failure_message).join("\n")
            raise ::RSpec::Expectations::ExpectationNotMetError, message
          end
        end
      end
    end
  end
end
