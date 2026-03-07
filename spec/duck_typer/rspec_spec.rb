require_relative "../../lib/duck_typer/rspec"

DuckTyper::RSpec.define_shared_example

RSpec.describe "an interface" do
  context "when interfaces match" do
    it_behaves_like "an interface", [
      Class.new { def foo(a:) = nil; def bar = nil },
      Class.new { def foo(a:) = nil; def bar = nil },
      Class.new { def foo(a:) = nil; def bar = nil }
    ]
  end

  context "when interfaces do match" do
    it "passes" do
      a = Class.new { def foo(a:) = nil; def bar = nil }
      b = Class.new { def foo(a:) = nil; def bar = nil }
      c = Class.new { def foo(a:) = nil; def bar = nil }

      expect([a, b, c]).to have_matching_interfaces
    end
  end

  context "when interfaces do not match" do
    it "reports a mismatch" do
      a = Class.new { def foo(a) = nil }
      b = Class.new { def foo(a) = nil }
      c = Class.new { def foo = nil }

      expect([a, b, c]).not_to have_matching_interfaces
    end

    it "includes differing signatures in the failure message" do
      a = Class.new { def foo(a) = nil }
      b = Class.new { def foo(a) = nil }
      c = Class.new { def foo = nil }

      matcher = have_matching_interfaces
      matcher.matches?([a, b, c])

      expect(matcher.failure_message).to include("foo(a)", "foo()")
    end
  end
end
