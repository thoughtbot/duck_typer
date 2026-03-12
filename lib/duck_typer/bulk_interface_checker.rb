# frozen_string_literal: true

module DuckTyper
  # Runs interface checks across all consecutive pairs of classes in a list.
  class BulkInterfaceChecker
    def initialize(objects = nil, namespace: nil, type: :instance_methods, partial_interface_methods: nil, strict: false, name: nil)
      raise ArgumentError, "cannot specify both objects and namespace" if objects && namespace
      raise ArgumentError, "objects or namespace is required" if objects.nil? && namespace.nil?

      @objects = resolve_objects(objects, namespace)
      raise ArgumentError, "more than one object is required" if @objects.size < 2

      name ||= namespace&.name
      @checker = InterfaceChecker.new(type:, partial_interface_methods:, strict:, name:)
    end

    def call(&block)
      @objects.each_cons(2).map do |left, right|
        result = @checker.call(left, right)
        block&.call(result)

        result
      end
    end

    private

    def resolve_objects(objects, namespace)
      namespace ? resolve_namespace(namespace) : Array(objects)
    end

    def resolve_namespace(namespace)
      namespace
        .constants
        .map { namespace.const_get(_1) }
        .select { _1.is_a?(Module) }
    end
  end
end
