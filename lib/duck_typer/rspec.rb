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
      ::RSpec.shared_examples name do |objects, type: :instance_methods, methods: nil|
        it "has compatible interfaces" do
          failures = DuckTyper::BulkInterfaceChecker.new(objects, type:, partial_interface_methods: methods).call.reject(&:match?)
          raise ::RSpec::Expectations::ExpectationNotMetError, failures.map(&:failure_message).join("\n") if failures.any?
        end
      end
    end
  end
end
