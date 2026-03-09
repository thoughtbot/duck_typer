require "minitest/autorun"
require_relative "../../lib/duck_typer"

class BulkInterfaceCheckerTest < Minitest::Test
  def checker(objects, **opts)
    DuckTyper::BulkInterfaceChecker.new(objects, **opts)
  end

  def test_raises_when_given_one_class
    assert_raises(ArgumentError) { checker([Class.new]) }
  end

  def test_raises_when_given_no_classes
    assert_raises(ArgumentError) { checker([]) }
  end

  def test_error_message_says_more_than_one_class_is_required
    error = assert_raises(ArgumentError) { checker([Class.new]) }

    assert_equal "more than one class is required", error.message
  end

  def test_does_not_raise_when_given_two_classes
    assert checker([Class.new, Class.new])
  end
end
