# frozen_string_literal: true

require "minitest/autorun"
require_relative "../../lib/duck_typer"
require_relative "../../lib/duck_typer/minitest"

class MethodInspectorTest < Minitest::Test
  include DuckTyper::Minitest

  def test_inspectors_have_compatible_interfaces
    assert_interfaces_match [
      DuckTyper::MethodInspector::ClassMethodInspector,
      DuckTyper::MethodInspector::InstanceMethodInspector
    ]
  end
end
