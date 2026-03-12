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
      expect([a, b, c]).to have_matching_duck_types
    end
  end

  context "when name is given" do
    it "passes" do
      a = Class.new { def bar = nil }
      b = Class.new { def bar = nil }

      expect([a, b]).to have_matching_interfaces(name: "Linkable")
    end
  end

  context "when namespace is given" do
    it "passes when all classes in the namespace match" do
      namespace = Module.new do
        const_set :Foo, Class.new { def bar = nil }
        const_set :Baz, Class.new { def bar = nil }
      end

      expect(namespace:).to have_matching_interfaces
    end

    it "fails when classes in the namespace do not match" do
      namespace = Module.new do
        const_set :Foo, Class.new { def bar = nil }
        const_set :Baz, Class.new { def baz = nil }
      end

      expect(namespace:).not_to have_matching_interfaces
    end

    it_behaves_like "an interface", namespace: Module.new {
      const_set :Foo, Class.new { def bar = nil }
      const_set :Baz, Class.new { def bar = nil }
    }
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
