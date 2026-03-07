# frozen_string_literal: true

module DuckTyper
  class InterfaceChecker
    class MethodInspector
      TYPES = %i[instance_methods class_methods].freeze

      def self.for(object, type)
        unless TYPES.include?(type)
          raise ArgumentError, "Invalid type #{type.inspect}, must be one of #{TYPES}"
        end

        if type == :class_methods
          ClassMethodInspector
        else
          InstanceMethodInspector
        end.new(object)
      end
    end

    class ClassMethodInspector
      def initialize(object)
        @object = object
      end

      def public_methods
        @object.public_methods - Object.methods
      end

      def parameters_for(method_name)
        @object.method(method_name).parameters
      end

      def display_name_for(method_name)
        "self.#{method_name}"
      end
    end

    class InstanceMethodInspector
      def initialize(object)
        @object = object
      end

      def public_methods
        @object.public_instance_methods - Object.methods
      end

      def parameters_for(method_name)
        @object.instance_method(method_name).parameters
      end

      def display_name_for(method_name)
        method_name
      end
    end
  end
end
