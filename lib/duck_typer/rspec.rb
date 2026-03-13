# frozen_string_literal: true

require_relative "../duck_typer"

RSpec::Matchers.define :have_matching_interfaces do |name: nil, type: :instance_methods, methods: nil, strict: false|
  match do |actual|
    namespace = actual.is_a?(Hash) ? actual[:namespace] : nil
    objects = namespace ? nil : actual

    checker = DuckTyper::BulkInterfaceChecker
      .new(objects, namespace:, type:, methods:, strict:, name:)

    @failures = checker.call.reject(&:match?)
    @failures.empty?
  end

  failure_message do
    @failures.map(&:failure_message).join("\n")
  end
end

RSpec::Matchers.alias_matcher :have_matching_duck_types, :have_matching_interfaces

module DuckTyper
  module RSpec
    def self.define_shared_example(name = "an interface")
      ::RSpec.shared_examples name do |*args, namespace: nil, name: nil, type: :instance_methods, methods: nil, strict: false|
        objects = namespace ? nil : args.first

        # We intentionally avoid reusing the have_matching_interfaces matcher
        # here. Since this shared example is defined in gem code, RSpec filters
        # it from its backtrace, causing the Failure/Error: line to show an
        # internal RSpec constant instead of useful context.
        it "has compatible interfaces" do
          checker = DuckTyper::BulkInterfaceChecker
            .new(objects, namespace:, type:, methods:, strict:, name:)

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
