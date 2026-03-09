# frozen_string_literal: true

module DuckTyper
  # Runs interface checks across all consecutive pairs of classes in a list.
  class BulkInterfaceChecker
    def initialize(objects, type: :instance_methods, partial_interface_methods: nil, strict: false)
      raise ArgumentError, "more than one class is required" if objects.size < 2

      @objects = objects
      @checker = InterfaceChecker.new(type:, partial_interface_methods:, strict:)
    end

    def call(&block)
      @objects.each_cons(2).map do |left, right|
        result = @checker.call(left, right)
        block&.call(result)
        result
      end
    end
  end
end
