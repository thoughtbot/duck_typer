# Duck Typer

[![CI](https://github.com/thoughtbot/duck_typer/actions/workflows/ci.yml/badge.svg)](https://github.com/thoughtbot/duck_typer/actions/workflows/ci.yml)

<div align="center">
  <img alt="Duck Typer mascot" src="assets/swan_mugshot.png" width="300">
</div>

> If it quacks like a duck, it's a duck... or is it?

Duck Typer enforces duck-typed interfaces in Ruby by comparing the
public method signatures of classes, surfacing mismatches through
your test suite.

## Why Duck Typer?

Ruby is a duck-typed language. When multiple classes play the same
role, what matters is not what they _are_, but what they _do_ — the
methods they respond to and the signatures they expose. No base
class required. No type annotations. No interface declarations.

Most approaches to enforcing this kind of contract pull Ruby away
from its dynamic nature: abstract base classes that raise
`NotImplementedError`, type-checking libraries that annotate method
signatures, or inheritance hierarchies that couple unrelated
classes. These work, but they're not very Ruby.

Duck Typer takes a different approach. It compares public method
signatures directly and reports mismatches through your test suite —
the natural place to enforce design constraints in Ruby. There's
nothing to annotate and nothing to inherit from. The classes remain
independent; Duck Typer simply verifies that they're speaking the
same language. The interface itself needs no declaration — it is
the intersection of methods your classes define in common, a living
document that evolves naturally.

It's also useful during active development. When an interface
evolves, implementations can easily fall out of sync. Duck Typer
catches that immediately and reports clear, precise error messages
showing exactly which signatures diverged — keeping your classes
aligned as the design changes.

## Installation

Add to your Gemfile:

```ruby
gem "duck_typer", group: :test
```

Then run:

```bash
bundle install
```

## Usage

When interfaces don't match, Duck Typer reports the differing
signatures:

```
Expected StripeProcessor and BraintreeProcessor to implement compatible
interfaces, but the following method signatures differ:

StripeProcessor: charge(amount, currency:)
BraintreeProcessor: charge(amount, currency:, description:)

StripeProcessor: refund(transaction_id)
BraintreeProcessor: refund(transaction_id, amount)
```

### Minitest

Require the Minitest integration and include the module in your
test class:

```ruby
require "duck_typer/minitest"

class PaymentProcessorTest < Minitest::Test
  include DuckTyper::Minitest
end
```

To make `assert_interfaces_match` available across all tests,
require the integration in `test_helper.rb` and include the module
in your base test class:

```ruby
# In test_helper.rb
require "duck_typer/minitest"

class ActiveSupport::TestCase
  include DuckTyper::Minitest
end
```

If you're not using Rails, include it in `Minitest::Test` directly:

```ruby
class Minitest::Test
  include DuckTyper::Minitest
end
```

Then use `assert_interfaces_match` to assert that a list of
classes share compatible interfaces:

```ruby
def test_payment_processors_have_compatible_interfaces
  assert_interfaces_match [
    StripeProcessor,
    PaypalProcessor,
    BraintreeProcessor
  ]
end
```

> If you prefer duck typing terminology, `assert_duck_types_match`
> is available as an alias.

By default, Duck Typer checks instance method interfaces. To check
class-level interfaces instead, pass `type: :class_methods`:

```ruby
assert_interfaces_match [StripeProcessor, PaypalProcessor],
  type: :class_methods
```

To check only a subset of methods (partial interface), use `methods:`:

```ruby
assert_interfaces_match [StripeProcessor, PaypalProcessor],
  methods: %i[charge refund]
```

This is useful if your class implements multiple interfaces, in
which case you can write an assertion for each.

To enforce that positional argument names also match (strict
mode), pass `strict: true`:

```ruby
assert_interfaces_match [StripeProcessor, PaypalProcessor],
  strict: true
```

By default, positional argument names are ignored — only their
count and kind (required, optional, rest) are compared. In strict
mode, names must match exactly. Keyword argument names always
matter regardless of this setting.

To include the interface name in failure messages, use `name:`:

```ruby
assert_interfaces_match [StripeProcessor, PaypalProcessor],
  name: "PaymentProcessor"
```

If your classes are organized under a module, pass it with
`namespace:` instead of listing them explicitly:

```ruby
assert_interfaces_match namespace: Payments
```

Duck Typer will resolve the module's constants and infer the
interface name from the module name when `name:` is not given.

### RSpec

Require the RSpec integration in your `spec_helper.rb`:

```ruby
require "duck_typer/rspec"
```

#### Matcher

Use `have_matching_interfaces` to assert that a list of classes
share compatible interfaces:

```ruby
RSpec.describe "payment processors" do
  it "have compatible interfaces" do
    expect([StripeProcessor, PaypalProcessor, BraintreeProcessor])
      .to have_matching_interfaces
  end
end
```

> If you prefer duck typing terminology, `have_matching_duck_types`
> is available as an alias.

For class-level interfaces, pass `type: :class_methods`:

```ruby
expect([StripeProcessor, PaypalProcessor])
  .to have_matching_interfaces(type: :class_methods)
```

To check only a subset of methods, use `methods:`:

```ruby
expect([StripeProcessor, PaypalProcessor])
  .to have_matching_interfaces(methods: %i[charge refund])
```

To enforce that positional argument names also match, pass
`strict: true`:

```ruby
expect([StripeProcessor, PaypalProcessor])
  .to have_matching_interfaces(strict: true)
```

To include the interface name in failure messages, use `name:`:

```ruby
expect([StripeProcessor, PaypalProcessor])
  .to have_matching_interfaces(name: "PaymentProcessor")
```

To check all classes in a module, pass it as a named subject:

```ruby
expect(namespace: Payments).to have_matching_interfaces
```

#### Shared example

If you prefer shared examples, register one in `spec_helper.rb`
by calling:

```ruby
DuckTyper::RSpec.define_shared_example
```

This registers a shared example named `"an interface"`. The name
can be changed by passing a custom one:

```ruby
DuckTyper::RSpec.define_shared_example("a compatible interface")
```

Then use it in your specs:

```ruby
RSpec.describe "payment processors" do
  it_behaves_like "an interface", [
    StripeProcessor,
    PaypalProcessor,
    BraintreeProcessor
  ]
end
```

The same `type:`, `methods:`, `strict:`, and `name:` options are
supported:

```ruby
it_behaves_like "an interface", [StripeProcessor, PaypalProcessor],
  type: :class_methods,
  methods: %i[charge refund],
  strict: true
```

To check all classes in a module, pass it with `namespace:`:

```ruby
it_behaves_like "an interface", namespace: Payments
```

## Limitations

By default, Duck Typer checks the **structure** of public method
signatures — the number of parameters, their kinds (required,
optional, keyword, rest, block), and keyword argument names. In
strict mode, positional argument names are also compared. It does
not
verify the following, which should be covered by your regular
test suite:

- **Parameter types.** Duck Typer only checks that both methods
  declare an `amount` parameter — not what type of value it
  expects. Two methods with identical signatures may still be
  incompatible if they expect different types.
- **Return types.** Two methods can have identical signatures
  but return completely different things.
- **Behavior.** Matching signatures are a necessary but not
  sufficient condition for duck typing to work correctly at
  runtime. Duck Typer catches structural drift, not semantic
  divergence.

Some things are intentionally out of scope:

- **Private methods and `initialize`.** Private methods are not
  part of a class's public interface — they are implementation
  details and intentionally excluded. The same applies to
  `initialize`: how an object is constructed is not an interface
  concern.

## Stability

Duck Typer is intentionally minimal. It reflects Ruby's own method
introspection API, which rarely changes — so the gem rarely needs
to either. When it does change, it will most likely be for additive reasons:
new API options, better error messages, or broader test framework
support. It is safe to depend on without worrying about churn.

## Development

After checking out the repo, run `bin/setup` to install
dependencies. You can also run `bin/console` for an interactive
prompt that will allow you to experiment.

To install this gem onto your local machine, run
`bundle exec rake install`. To release a new version, update the
version number in `version.rb`, and then run
`bundle exec rake release`, which will create a git tag for the
version, push git commits and the created tag, and push the `.gem`
file to [rubygems.org](https://rubygems.org).

## Contributing

See the [CONTRIBUTING] document.
Thank you, [contributors]!

[CONTRIBUTING]: CONTRIBUTING.md
[contributors]: https://github.com/thoughtbot/duck_typer/graphs/contributors

## License

Duck Typer is Copyright (c) thoughtbot, inc.
It is free software, and may be redistributed
under the terms specified in the [LICENSE] file.

[LICENSE]: /LICENSE

## About thoughtbot

![thoughtbot](https://thoughtbot.com/thoughtbot-logo-for-readmes.svg)

This repo is maintained and funded by thoughtbot, inc.
The names and logos for thoughtbot are trademarks of thoughtbot, inc.

We love open source software!
See [our other projects][community].
We are [available for hire][hire].

[community]: https://thoughtbot.com/community?utm_source=github
[hire]: https://thoughtbot.com/hire-us?utm_source=github
