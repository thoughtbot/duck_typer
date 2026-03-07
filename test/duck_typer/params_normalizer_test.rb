require "minitest/autorun"
require_relative "../../lib/duck_typer"
require_relative "../../lib/duck_typer/minitest"

class ParamsNormalizerTest < Minitest::Test
  include DuckTyper::Minitest

  ParamsNormalizer = DuckTyper::InterfaceChecker::ParamsNormalizer
  NullParamsNormalizer = DuckTyper::InterfaceChecker::NullParamsNormalizer

  def normalize(params)
    ParamsNormalizer.call(params)
  end

  # Interface

  def test_matches_null_params_normalizer_interface
    assert_interfaces_match [ParamsNormalizer, NullParamsNormalizer], type: :class_methods
  end

  # Sequential params

  def test_replaces_sequential_param_names_with_placeholders
    params = [[:req, :x], [:opt, :y], [:rest, :z]]

    assert_equal [[:req, :a], [:opt, :b], [:rest, :c]], normalize(params)
  end

  # Keyword params

  def test_preserves_keyword_param_names
    params = [[:keyreq, :name], [:key, :role]]

    assert_equal [[:keyreq, :name], [:key, :role]], normalize(params)
  end

  def test_sorts_keyword_params_alphabetically
    params = [[:key, :role], [:keyreq, :name]]

    assert_equal [[:keyreq, :name], [:key, :role]], normalize(params)
  end

  def test_places_keyword_params_after_sequential_params
    params = [[:keyreq, :name], [:req, :x]]

    assert_equal [[:req, :a], [:keyreq, :name]], normalize(params)
  end

  # Mixed

  def test_normalizes_all_param_types_together
    params = [
      [:req, :x],
      [:opt, :y],
      [:rest, :z],
      [:keyreq, :name],
      [:key, :role],
      [:keyrest, :opts],
      [:block, :blk]
    ]

    assert_equal [
      [:req, :a],
      [:opt, :b],
      [:rest, :c],
      [:keyrest, :d],
      [:block, :e],
      [:keyreq, :name],
      [:key, :role]
    ], normalize(params)
  end

  def test_nokey_param_name_is_preserved
    params = [[:req, :x], [:nokey, nil]]

    assert_equal [[:req, :a], [:nokey, nil]], normalize(params)
  end
end
