require "minitest/autorun"
require_relative "../../lib/duck_typer/minitest"

class MinitestHelperTest < Minitest::Test
  include DuckTyper::Minitest

  def test_passes_when_interfaces_match
    a = Class.new { def foo(a:) = nil; def bar = nil }
    b = Class.new { def foo(a:) = nil; def bar = nil }
    c = Class.new { def foo(a:) = nil; def bar = nil }

    assert_interfaces_match [a, b, c]
    assert_duck_types_match [a, b, c]
  end

  def test_passes_for_matching_pairs_even_when_another_class_mismatches
    a = Class.new { def foo(a) = nil }
    b = Class.new { def foo(a) = nil }
    c = Class.new { def foo = nil }

    assert_interfaces_match [a, b]
    assert_raises(Minitest::Assertion) { assert_interfaces_match [a, b, c] }
  end

  def test_fails_when_interfaces_do_not_match
    a = Class.new { def foo(a) = nil }
    b = Class.new { def foo(a) = nil }
    c = Class.new { def foo = nil }

    assert_raises(Minitest::Assertion) do
      assert_interfaces_match [a, b, c]
    end
  end

  def test_failure_message_includes_method_signatures
    a = Class.new { def foo(a) = nil }
    b = Class.new { def foo(a) = nil }
    c = Class.new { def foo = nil }

    error = assert_raises(Minitest::Assertion) do
      assert_interfaces_match [a, b, c]
    end

    assert_includes error.message, "foo(a)"
    assert_includes error.message, "foo()"
  end
end
