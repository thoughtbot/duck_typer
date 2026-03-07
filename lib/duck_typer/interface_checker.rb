# frozen_string_literal: true

require_relative "interface_checker/result"
require_relative "interface_checker/method_inspector"
require_relative "interface_checker/params_normalizer"

module DuckTyper
  # Compares the public method signatures of two classes and reports mismatches.
  class InterfaceChecker
    TYPES = %i[instance_methods class_methods].freeze

    def initialize(type: :instance_methods, partial_interface_methods: nil)
      unless TYPES.include?(type)
        raise ArgumentError, "Invalid type #{type.inspect}, must be one of #{TYPES}"
      end

      @type = type
      @partial_interface_methods = partial_interface_methods
      @inspectors = Hash.new { |h, k| h[k] = MethodInspector.for(k, @type) }
    end

    def call(left, right)
      left_params = params_for_comparison(left, ParamsNormalizer)
      right_params = params_for_comparison(right, ParamsNormalizer)
      diff = (left_params - right_params) + (right_params - left_params)

      match = -> { match?(left_params, right_params) }
      method_signatures = -> { build_method_signatures(left, right, diff) }

      Result.new(left:, right:, match:, method_signatures:)
    end

    private

    def match?(left_params, right_params)
      diff = (left_params - right_params) + (right_params - left_params)
      diff.empty?
    end

    def build_method_signatures(left, right, diff)
      methods = diff.map(&:first).uniq
      left_params = params_for_comparison(left).to_h.slice(*methods)
      right_params = params_for_comparison(right).to_h.slice(*methods)

      methods.map do |method_name|
        <<~DIFF
          #{join_signature(left, method_name, left_params)}
          #{join_signature(right, method_name, right_params)}
        DIFF
      end.join("\n")
    end

    def join_signature(object, method_name, params)
      inspector = @inspectors[object]
      display_name = inspector.display_name_for(method_name)

      signature = if params[method_name]
        "#{display_name}(#{params[method_name].join(", ")})"
      else
        "#{display_name} not defined"
      end

      "#{object}: #{signature}"
    end

    def method_params(inspector, method_name, object)
      inspector.parameters_for(method_name)
    rescue NameError
      raise MethodNotFoundError, "undefined method `#{method_name}' for #{object}"
    end

    def params_for_comparison(object, params_processor = -> { _1 })
      inspector = @inspectors[object]
      methods = @partial_interface_methods || inspector.public_methods

      methods.map do |method_name|
        params = method_params(inspector, method_name, object)
        args = params_processor.call(params).map do |type, name|
          case type
          when :key then "#{name}: :opt"
          when :keyreq then "#{name}:"
          when :keyrest then "**#{name}"
          when :block then "&#{name}"
          when :req then name.to_s
          when :opt then "#{name} = :opt"
          when :rest then "*#{name}"
          end
        end

        [method_name, args]
      end
    end
  end
end
