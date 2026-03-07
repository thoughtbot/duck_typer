# frozen_string_literal: true

require_relative "interface_checker/result"
require_relative "interface_checker/method_inspector"
require_relative "interface_checker/params_normalizer"
require_relative "interface_checker/null_params_normalizer"

module DuckTyper
  # Compares the public method signatures of two classes and reports mismatches.
  class InterfaceChecker
    def initialize(type: :instance_methods, partial_interface_methods: nil)
      @type = type
      @partial_interface_methods = partial_interface_methods
      @inspectors = Hash.new { |h, k| h[k] = MethodInspector.for(k, @type) }
    end

    def call(left, right)
      diff = calculate_diff(left, right)
      match = -> { diff.empty? }
      diff_message = -> { diff_message(left, right, diff) }

      Result.new(left:, right:, match:, diff_message:)
    end

    private

    def calculate_diff(left, right)
      left_params = params_for_comparison(left, ParamsNormalizer)
      right_params = params_for_comparison(right, ParamsNormalizer)

      (left_params - right_params) + (right_params - left_params)
    end

    def params_for_comparison(object, params_processor)
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
          when :nokey then "**nil"
          end
        end

        [method_name, args]
      end
    end

    def method_params(inspector, method_name, object)
      inspector.parameters_for(method_name)
    rescue NameError
      raise MethodNotFoundError, "undefined method `#{method_name}' for #{object}"
    end

    def diff_message(left, right, diff)
      methods = diff.map(&:first).uniq
      left_params = params_for_comparison(left, NullParamsNormalizer)
      right_params = params_for_comparison(right, NullParamsNormalizer)

      methods.map do |method_name|
        <<~DIFF
          #{join_signature(left, method_name, left_params)}
          #{join_signature(right, method_name, right_params)}
        DIFF
      end.join("\n")
    end

    def join_signature(object, method_name, all_params)
      inspector = @inspectors[object]
      display_name = inspector.display_name_for(method_name)
      method_params = all_params.assoc(method_name)&.last

      signature = if method_params
        "#{display_name}(#{method_params.join(", ")})"
      else
        "#{display_name} not defined"
      end

      "#{object}: #{signature}"
    end
  end
end
