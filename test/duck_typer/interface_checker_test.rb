require "minitest/autorun"
require_relative "../../lib/duck_typer"

class InterfaceCheckerTest < Minitest::Test
  def call_checker(left, right, **opts)
    checker = DuckTyper::InterfaceChecker.new(**opts)
    checker.call(left, right)
  end

  def match?(left, right, **opts)
    call_checker(left, right, **opts).match?
  end

  # Basic interface matching

  def test_identical_interfaces_match
    left = Class.new { def foo = nil; def bar = nil }
    right = Class.new { def foo = nil; def bar = nil }

    assert match?(left, right)
  end

  def test_different_method_names_do_not_match
    left = Class.new { def foo = nil }
    right = Class.new { def bar = nil }

    refute match?(left, right)
  end

  def test_extra_method_on_one_side_does_not_match
    left = Class.new { def foo = nil; def bar = nil }
    right = Class.new { def foo = nil }

    refute match?(left, right)
  end

  # Positional arguments

  def test_same_required_positional_args_match
    left = Class.new { def foo(a, b) = nil }
    right = Class.new { def foo(x, y) = nil }

    assert match?(left, right)
  end

  def test_different_required_positional_arg_count_does_not_match
    left = Class.new { def foo(a, b) = nil }
    right = Class.new { def foo(a) = nil }

    refute match?(left, right)
  end

  def test_optional_positional_arg_vs_none_does_not_match
    left = Class.new { def foo(a = nil) = nil }
    right = Class.new { def foo = nil }

    refute match?(left, right)
  end

  def test_same_optional_positional_args_match
    left = Class.new { def foo(a = nil) = nil }
    right = Class.new { def foo(x = nil) = nil }

    assert match?(left, right)
  end

  def test_required_and_optional_positional_args_match
    left = Class.new { def foo(a, b = nil) = nil }
    right = Class.new { def foo(x, y = nil) = nil }

    assert match?(left, right)
  end

  # Keyword arguments

  def test_same_required_keyword_args_match
    left = Class.new { def foo(a:) = nil }
    right = Class.new { def foo(a:) = nil }

    assert match?(left, right)
  end

  def test_different_required_keyword_arg_names_do_not_match
    left = Class.new { def foo(a:) = nil }
    right = Class.new { def foo(b:) = nil }

    refute match?(left, right)
  end

  def test_same_optional_keyword_args_match
    left = Class.new { def foo(a: nil) = nil }
    right = Class.new { def foo(a: nil) = nil }

    assert match?(left, right)
  end

  def test_optional_keyword_arg_vs_none_does_not_match
    left = Class.new { def foo(a: nil) = nil }
    right = Class.new { def foo = nil }

    refute match?(left, right)
  end

  def test_required_keyword_args_match_regardless_of_order
    left = Class.new { def foo(a:, b:) = nil }
    right = Class.new { def foo(b:, a:) = nil }

    assert match?(left, right)
  end

  def test_optional_keyword_args_match_regardless_of_order
    left = Class.new { def foo(a: nil, b: nil) = nil }
    right = Class.new { def foo(b: nil, a: nil) = nil }

    assert match?(left, right)
  end

  def test_mixed_args_match_regardless_of_keyword_order
    left = Class.new { def foo(a, b:, c:, d: nil, &blk) = nil }
    right = Class.new { def foo(x, c:, b:, d: nil, &block) = nil }

    assert match?(left, right)
  end

  def test_required_keyword_vs_optional_keyword_does_not_match
    left = Class.new { def foo(a:) = nil }
    right = Class.new { def foo(a: nil) = nil }

    refute match?(left, right)
  end

  def test_mixed_required_and_optional_keyword_args_match
    left = Class.new { def foo(a:, b: nil) = nil }
    right = Class.new { def foo(a:, b: nil) = nil }

    assert match?(left, right)
  end

  # Rest arguments

  def test_same_rest_args_match
    left = Class.new { def foo(*args) = nil }
    right = Class.new { def foo(*args) = nil }

    assert match?(left, right)
  end

  def test_rest_arg_vs_none_does_not_match
    left = Class.new { def foo(*args) = nil }
    right = Class.new { def foo = nil }

    refute match?(left, right)
  end

  def test_rest_arg_name_does_not_matter
    left = Class.new { def foo(*args) = nil }
    right = Class.new { def foo(*rest) = nil }

    assert match?(left, right)
  end

  def test_rest_arg_with_required_positional_match
    left = Class.new { def foo(a, *args) = nil }
    right = Class.new { def foo(x, *rest) = nil }

    assert match?(left, right)
  end

  def test_rest_arg_with_different_required_positional_does_not_match
    left = Class.new { def foo(a, b, *args) = nil }
    right = Class.new { def foo(a, *args) = nil }

    refute match?(left, right)
  end

  def test_rest_arg_with_keyword_args_match
    left = Class.new { def foo(*args, a:, b: nil) = nil }
    right = Class.new { def foo(*rest, a:, b: nil) = nil }

    assert match?(left, right)
  end

  def test_rest_arg_with_different_keyword_args_does_not_match
    left = Class.new { def foo(*args, a:) = nil }
    right = Class.new { def foo(*args, b:) = nil }

    refute match?(left, right)
  end

  # No-keyword arguments

  def test_no_keyword_args_match
    left = Class.new { def foo(**nil) = nil }
    right = Class.new { def foo(**nil) = nil }

    assert match?(left, right)
  end

  def test_no_keyword_arg_vs_none_does_not_match
    left = Class.new { def foo(**nil) = nil }
    right = Class.new { def foo = nil }

    refute match?(left, right)
  end

  def test_nokey_with_positional_and_block_match
    left = Class.new { def foo(a, b, **nil, &blk) = nil }
    right = Class.new { def foo(x, y, **nil, &block) = nil }

    assert match?(left, right)
  end

  def test_nokey_vs_keyrest_does_not_match
    left = Class.new { def foo(a, **nil) = nil }
    right = Class.new { def foo(a, **opts) = nil }

    refute match?(left, right)
  end

  # Keyword rest arguments

  def test_same_keyrest_args_match
    left = Class.new { def foo(**opts) = nil }
    right = Class.new { def foo(**opts) = nil }

    assert match?(left, right)
  end

  def test_keyrest_arg_vs_none_does_not_match
    left = Class.new { def foo(**opts) = nil }
    right = Class.new { def foo = nil }

    refute match?(left, right)
  end

  def test_keyrest_arg_name_does_not_matter
    left = Class.new { def foo(**opts) = nil }
    right = Class.new { def foo(**kwargs) = nil }

    assert match?(left, right)
  end

  def test_keyrest_arg_with_required_keyword_args_match
    left = Class.new { def foo(a:, **opts) = nil }
    right = Class.new { def foo(a:, **kwargs) = nil }

    assert match?(left, right)
  end

  def test_keyrest_arg_with_different_required_keyword_args_does_not_match
    left = Class.new { def foo(a:, **opts) = nil }
    right = Class.new { def foo(b:, **opts) = nil }

    refute match?(left, right)
  end

  def test_keyrest_arg_with_positional_and_keyword_args_match
    left = Class.new { def foo(a, b, c:, **opts) = nil }
    right = Class.new { def foo(x, y, c:, **kwargs) = nil }

    assert match?(left, right)
  end

  # Block arguments

  def test_same_block_args_match
    left = Class.new { def foo(&) = nil }
    right = Class.new { def foo(&) = nil }

    assert match?(left, right)
  end

  def test_block_arg_vs_none_does_not_match
    left = Class.new { def foo(&) = nil }
    right = Class.new { def foo = nil }

    refute match?(left, right)
  end

  def test_block_arg_name_does_not_matter
    left = Class.new { def foo(&) = nil }
    right = Class.new { def foo(&) = nil }

    assert match?(left, right)
  end

  def test_block_arg_with_positional_and_keyword_args_match
    left = Class.new { def foo(a, b:, &block) = nil }
    right = Class.new { def foo(x, b:, &blk) = nil }

    assert match?(left, right)
  end

  # Partial interface

  def test_partial_interface_matches_only_specified_methods
    left = Class.new { def foo = nil; def bar(a) = nil; def baz = nil }
    right = Class.new { def foo = nil; def bar(a) = nil }

    assert match?(left, right, partial_interface_methods: %i[foo bar])
  end

  def test_partial_interface_does_not_match_when_specified_method_differs
    left = Class.new { def foo(a) = nil; def bar = nil }
    right = Class.new { def foo = nil; def bar = nil }

    refute match?(left, right, partial_interface_methods: [:foo])
  end

  def test_partial_interface_ignores_differing_methods_outside_the_list
    left = Class.new { def foo = nil; def bar(a, b) = nil }
    right = Class.new { def foo = nil; def bar = nil }

    assert match?(left, right, partial_interface_methods: [:foo])
  end

  # Class-level interface

  def test_matching_class_methods_match
    left = Class.new { def self.foo = nil; def self.bar = nil }
    right = Class.new { def self.foo = nil; def self.bar = nil }

    assert match?(left, right, type: :class_methods)
  end

  def test_differing_class_methods_do_not_match
    left = Class.new { def self.foo = nil }
    right = Class.new { def self.bar = nil }

    refute match?(left, right, type: :class_methods)
  end

  def test_class_method_signatures_must_match
    left = Class.new { def self.foo(a, b) = nil }
    right = Class.new { def self.foo(a) = nil }

    refute match?(left, right, type: :class_methods)
  end

  def test_class_level_check_ignores_instance_methods
    left = Class.new { def self.foo = nil; def bar = nil }
    right = Class.new { def self.foo = nil }

    assert match?(left, right, type: :class_methods)
  end

  # Error handling

  def test_invalid_type_raises_argument_error
    left = Class.new { def foo = nil }
    right = Class.new { def foo = nil }

    assert_raises(ArgumentError) { call_checker(left, right, type: :invalid) }
  end

  def test_invalid_type_error_message_includes_invalid_value
    left = Class.new { def foo = nil }
    right = Class.new { def foo = nil }

    error = assert_raises(ArgumentError) { call_checker(left, right, type: :invalid) }

    assert_includes error.message, ":invalid"
  end

  def test_invalid_type_error_message_includes_valid_options
    left = Class.new { def foo = nil }
    right = Class.new { def foo = nil }

    error = assert_raises(ArgumentError) { call_checker(left, right, type: :invalid) }

    assert_includes error.message, "instance_methods"
    assert_includes error.message, "class_methods"
  end

  def test_more_than_26_positional_params_raises_too_many_parameters_error
    left = Class.new { def foo(a, b, c, d, e, f, g, h, i, j, k, l, m, n, o, p, q, r, s, t, u, v, w, x, y, z, aa) = nil }
    right = Class.new { def foo(a, b, c, d, e, f, g, h, i, j, k, l, m, n, o, p, q, r, s, t, u, v, w, x, y, z, aa) = nil }

    error = assert_raises(DuckTyper::TooManyParametersError) { match?(left, right) }

    assert_equal "too many positional parameters, maximum supported is 26", error.message
  end

  def test_partial_interface_method_missing_on_right_raises_method_not_found_error
    left = Class.new { def foo = nil }
    right = Class.new {}

    assert_raises(DuckTyper::MethodNotFoundError) do
      call_checker(left, right, partial_interface_methods: [:foo])
    end
  end

  def test_partial_interface_method_missing_on_left_raises_method_not_found_error
    left = Class.new {}
    right = Class.new { def foo = nil }

    assert_raises(DuckTyper::MethodNotFoundError) do
      call_checker(left, right, partial_interface_methods: [:foo])
    end
  end

  def test_partial_interface_method_not_found_error_message
    left = Class.new {}
    right = Class.new { def foo = nil }

    error = assert_raises(DuckTyper::MethodNotFoundError) do
      call_checker(left, right, partial_interface_methods: [:foo])
    end

    assert_equal "undefined method `foo' for #{left}", error.message
  end

  # failure_message output

  def test_failure_message_returns_nil_when_interfaces_match
    left = Class.new { def foo = nil }
    right = Class.new { def foo = nil }

    assert_nil call_checker(left, right).failure_message
  end

  def test_failure_message_includes_class_names
    left = Class.new { def foo(a) = nil }
    right = Class.new { def foo = nil }

    message = call_checker(left, right).failure_message

    assert_includes message, left.to_s
    assert_includes message, right.to_s
  end

  def test_failure_message_includes_differing_method_signatures
    left = Class.new { def foo(a) = nil }
    right = Class.new { def foo = nil }

    message = call_checker(left, right).failure_message

    assert_includes message, "foo(a)"
    assert_includes message, "foo()"
  end

  def test_failure_message_shows_not_defined_for_missing_method
    left = Class.new { def foo = nil; def bar = nil }
    right = Class.new { def foo = nil }

    message = call_checker(left, right).failure_message

    assert_includes message, "bar not defined"
  end

  def test_failure_message_uses_self_prefix_for_class_methods
    left = Class.new { def self.foo(a) = nil }
    right = Class.new { def self.foo = nil }

    message = call_checker(left, right, type: :class_methods).failure_message

    assert_includes message, "self.foo"
  end

  def test_failure_message_includes_nokey_signature
    left = Class.new { def foo(**nil) = nil }
    right = Class.new { def foo = nil }

    message = call_checker(left, right).failure_message

    assert_includes message, "**nil"
  end

  def test_positional_arg_names_are_preserved_in_failure_message
    left = Class.new { def foo(bananas, coconuts, mangoes, papayas) = nil }
    right = Class.new { def foo = nil }

    message = call_checker(left, right).failure_message

    assert_includes message, "foo(bananas, coconuts, mangoes, papayas)"
  end

  def test_keyword_arg_names_are_preserved_in_failure_message
    left = Class.new do
      def foo(bananas, coconuts, *others, format:, locale: nil, **opts, &blk) = nil
    end
    right = Class.new { def foo = nil }

    message = call_checker(left, right).failure_message

    assert_includes(
      message,
      "foo(bananas, coconuts, *others, format:, locale: :opt, **opts, &blk)"
    )
  end
end
