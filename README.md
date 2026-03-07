# DuckTyper

[![CI](https://github.com/thoughtbot/duck_typer/actions/workflows/ci.yml/badge.svg)](https://github.com/thoughtbot/duck_typer/actions/workflows/ci.yml)

DuckTyper enforces duck-typed interfaces in Ruby by comparing the
public method signatures of classes, surfacing mismatches through
your test suite.

## Why DuckTyper?

Ruby is a duck-typed language. When multiple classes play the same
role, what matters is not what they _are_, but what they _do_ — the
methods they respond to and the signatures they expose. No base
class required. No type annotations. No interface declarations.

Most approaches to enforcing this kind of contract pull Ruby away
from its dynamic nature: abstract base classes that raise
`NotImplementedError`, type-checking libraries that annotate method
signatures, or inheritance hierarchies that couple unrelated
classes. These work, but they're not very Ruby.

DuckTyper takes a different approach. It compares public method
signatures directly and reports mismatches through your test suite —
the natural place to enforce design constraints in Ruby. There's
nothing to annotate and nothing to inherit from. The classes remain
independent; DuckTyper simply verifies that they're speaking the
same language. The interface itself needs no declaration — it is
the intersection of methods your classes define in common, a living
document that evolves naturally.

It's also useful during active development. When an interface
evolves, implementations can easily fall out of sync. DuckTyper
catches that immediately and reports clear, precise error messages
showing exactly which signatures diverged — keeping your classes
aligned as the design changes.

## Installation

Add to your Gemfile:

```ruby
gem "duck_typer"
```

Then run:

```bash
bundle install
```

## Usage

When interfaces don't match, DuckTyper reports the differing
signatures:

```
Expected StripeProcessor and BraintreeProcessor to have compatible
method signatures, but the following signatures do not match:

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

To make `assert_interface_matches` available across all tests,
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

Then use `assert_interface_matches` to assert that a list of
classes share compatible interfaces:

```ruby
def test_payment_processors_have_compatible_interfaces
  assert_interface_matches [StripeProcessor, PaypalProcessor, BraintreeProcessor]
end
```

The same `type:` and `methods:` options are supported:

```ruby
assert_interface_matches [StripeProcessor, PaypalProcessor],
  type: :class_methods,
  methods: %i[charge refund]
```

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
    expect([StripeProcessor, PaypalProcessor, BraintreeProcessor]).to have_matching_interfaces
  end
end
```

For class-level interfaces, pass `type: :class_methods`:

```ruby
expect([StripeProcessor, PaypalProcessor]).to have_matching_interfaces(type: :class_methods)
```

To check only a subset of methods, use `methods:`:

```ruby
expect([StripeProcessor, PaypalProcessor]).to have_matching_interfaces(methods: %i[charge refund])
```

#### Shared example

If you prefer shared examples, register one in `spec_helper.rb`
by calling:

```ruby
DuckTyper::RSpec.define_shared_example
```

This registers a shared example named `"an interface"`. To avoid
conflicts with an existing shared example of the same name, pass
a custom name:

```ruby
DuckTyper::RSpec.define_shared_example("a compatible interface")
```

Then use it in your specs:

```ruby
RSpec.describe "payment processors" do
  it_behaves_like "an interface", [StripeProcessor, PaypalProcessor, BraintreeProcessor]
end
```

The same `type:` and `methods:` options are supported:

```ruby
it_behaves_like "an interface", [StripeProcessor, PaypalProcessor],
  type: :class_methods,
  methods: %i[charge refund]
```

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

DuckTyper is Copyright (c) thoughtbot, inc.
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
