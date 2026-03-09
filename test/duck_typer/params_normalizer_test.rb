require "minitest/autorun"
require_relative "../../lib/duck_typer"
require_relative "../../lib/duck_typer/minitest"

class ParamsNormalizerTest < Minitest::Test
  include DuckTyper::Minitest

  ParamsNormalizer = DuckTyper::ParamsNormalizer
  DefaultParamsNormalizer = DuckTyper::ParamsNormalizer::DefaultParamsNormalizer
  StrictParamsNormalizer = DuckTyper::ParamsNormalizer::StrictParamsNormalizer
  KeywordNormalizer = DuckTyper::ParamsNormalizer::KeywordNormalizer
  SequentialNormalizer = DuckTyper::ParamsNormalizer::SequentialNormalizer
  NullParamsNormalizer = DuckTyper::ParamsNormalizer::NullParamsNormalizer

  # Interface

  def test_normalizers_share_the_same_interface
    assert_interfaces_match [
      DefaultParamsNormalizer,
      StrictParamsNormalizer,
      KeywordNormalizer,
      SequentialNormalizer,
      NullParamsNormalizer
    ], type: :class_methods
  end

  # ParamsNormalizer.for

  def test_for_returns_default_params_normalizer_when_not_strict
    assert_equal DefaultParamsNormalizer, ParamsNormalizer.for(strict: false)
  end

  def test_for_returns_strict_params_normalizer_when_strict
    assert_equal StrictParamsNormalizer, ParamsNormalizer.for(strict: true)
  end

  # DefaultParamsNormalizer

  def test_default_normalizes_all_param_types_together
    params = [
      [:req, :x],
      [:opt, :y],
      [:rest, :z],
      [:keyreq, :name],
      [:key, :role],
      [:keyrest, :opts],
      [:block, :blk],
      [:nokey, nil]
    ]

    assert_equal [
      [:req, :a],
      [:opt, :b],
      [:rest, :c],
      [:keyrest, :d],
      [:block, :e],
      [:nokey, nil],
      [:keyreq, :name],
      [:key, :role]
    ], DefaultParamsNormalizer.call(params)
  end

  # StrictParamsNormalizer

  def test_strict_preserves_positional_param_names
    params = [[:req, :x], [:opt, :y], [:rest, :z]]

    assert_equal [[:req, :x], [:opt, :y], [:rest, :z]], StrictParamsNormalizer.call(params)
  end

  def test_strict_sorts_keyword_params_alphabetically
    params = [[:key, :role], [:keyreq, :name]]

    assert_equal [[:keyreq, :name], [:key, :role]], StrictParamsNormalizer.call(params)
  end

  def test_strict_normalizes_all_param_types_together
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
      [:req, :x],
      [:opt, :y],
      [:rest, :z],
      [:keyrest, :opts],
      [:block, :blk],
      [:keyreq, :name],
      [:key, :role]
    ], StrictParamsNormalizer.call(params)
  end

  # KeywordNormalizer

  def test_preserves_keyword_param_names
    params = [[:keyreq, :name], [:key, :role]]

    assert_equal [[:keyreq, :name], [:key, :role]], KeywordNormalizer.call(params)
  end

  def test_sorts_keyword_params_alphabetically
    params = [[:key, :role], [:keyreq, :name]]

    assert_equal [[:keyreq, :name], [:key, :role]], KeywordNormalizer.call(params)
  end

  def test_places_keyword_params_after_sequential_params
    params = [[:keyreq, :name], [:req, :x]]

    assert_equal [[:req, :x], [:keyreq, :name]], KeywordNormalizer.call(params)
  end

  # SequentialNormalizer

  def test_replaces_sequential_param_names_with_placeholders
    params = [[:req, :x], [:opt, :y], [:rest, :z]]

    assert_equal [[:req, :a], [:opt, :b], [:rest, :c]], SequentialNormalizer.call(params)
  end

  def test_does_not_replace_keyword_param_names
    params = [[:keyreq, :name], [:key, :role]]

    assert_equal [[:keyreq, :name], [:key, :role]], SequentialNormalizer.call(params)
  end

  def test_preserves_nokey_param_name
    params = [[:req, :x], [:nokey, nil]]

    assert_equal [[:req, :a], [:nokey, nil]], SequentialNormalizer.call(params)
  end

  def test_too_many_positional_params_raises_too_many_parameters_error
    params = ("a".."z").map { |l| [:req, l.to_sym] } + [[:req, :aa]]

    assert_raises(DuckTyper::TooManyParametersError) { SequentialNormalizer.call(params) }
  end
end
