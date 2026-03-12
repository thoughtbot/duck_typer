require "minitest/autorun"
require_relative "../../lib/duck_typer"

class BulkInterfaceCheckerTest < Minitest::Test
  def new_checker(objects = nil, **opts)
    DuckTyper::BulkInterfaceChecker.new(objects, **opts)
  end

  def test_raises_when_given_one_class
    assert_raises(ArgumentError) { new_checker([Class.new]) }
  end

  def test_raises_when_given_no_classes
    assert_raises(ArgumentError) { new_checker([]) }
  end

  def test_error_message_says_more_than_one_object_is_required
    error = assert_raises(ArgumentError) { new_checker([Class.new]) }

    assert_equal "more than one object is required", error.message
  end

  def test_does_not_raise_when_given_two_classes
    assert new_checker([Class.new, Class.new])
  end

  def test_raises_when_given_both_objects_and_namespace
    namespace = Module.new do
      const_set :Foo, Class.new
      const_set :Bar, Class.new
    end

    error = assert_raises(ArgumentError) do
      new_checker([Class.new, Class.new], namespace:)
    end

    assert_equal "cannot specify both objects and namespace", error.message
  end

  def test_raises_when_given_neither_objects_nor_namespace
    error = assert_raises(ArgumentError) { new_checker }

    assert_equal "objects or namespace is required", error.message
  end

  def test_passes_when_namespace_classes_match
    namespace = Module.new do
      const_set :Foo, Class.new { def bar = nil }
      const_set :Baz, Class.new { def bar = nil }
    end

    results = new_checker(namespace:).call

    assert results.all?(&:match?)
  end

  def test_detects_mismatch_in_namespace_classes
    namespace = Module.new do
      const_set :Foo, Class.new { def bar = nil }
      const_set :Baz, Class.new { def baz = nil }
    end

    results = new_checker(namespace:).call

    refute results.all?(&:match?)
  end

  def test_namespace_ignores_non_module_constants
    namespace = Module.new do
      const_set :VERSION, "1.0"
      const_set :Foo, Class.new { def bar = nil }
      const_set :Baz, Class.new { def bar = nil }
    end

    results = new_checker(namespace:).call

    assert results.all?(&:match?)
  end

  NamedNamespace = Module.new do
    const_set :Foo, Class.new { def bar = nil }
    const_set :Baz, Class.new { def baz = nil }
  end

  def test_name_is_inferred_from_namespace
    result = new_checker(namespace: NamedNamespace).call.first

    assert_includes result.failure_message, "BulkInterfaceCheckerTest::NamedNamespace"
  end

  def test_explicit_name_takes_priority_over_inferred_namespace_name
    result = new_checker(namespace: NamedNamespace, name: "Linkable").call.first

    assert_includes result.failure_message, '"Linkable"'
  end
end
