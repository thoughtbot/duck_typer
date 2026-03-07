module DuckTyper
  class InterfaceChecker
    # Normalizes method parameters to enable interface comparison. For
    # example, two methods may use different names for positional
    # arguments, but if the parameter types and order match, they should
    # be considered equivalent. This class replaces argument names with
    # sequential placeholders when appropriate, focusing the comparison on
    # parameter structure rather than naming.
    class ParamsNormalizer
      def self.call(params)
        sequential_name = ("a".."z").to_enum

        params.map do |type, name|
          name = next_sequential_param(sequential_name) if %i[req opt rest keyrest block].include?(type)

          [type, name]
        end
      end

      def self.next_sequential_param(enumerator)
        enumerator.next
      rescue StopIteration
        raise TooManyParametersError, "too many positional parameters, maximum supported is 26"
      end
      private_class_method :next_sequential_param
    end
  end
end
