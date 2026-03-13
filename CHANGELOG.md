# Changelog

## [0.5.0] - 2026-03-13

### Added
- `name:` option: includes the interface name in failure messages
  (e.g. `compatible "Linkable" interfaces`)
- `namespace:` option: resolves a module's constants as the list of
  objects to compare; infers the interface name from the module name
  when `name:` is not given
- Strict mode now notes itself in the failure message:
  `(strict mode: positional argument names must match)`
- `BulkInterfaceChecker` and `InterfaceChecker` raise
  `PrivateMethodError` when a private method is specified in
  `methods:`

### Changed
- `partial_interface_methods:` renamed to `methods:` across
  `BulkInterfaceChecker`, `InterfaceChecker`, `assert_interfaces_match`,
  and `have_matching_interfaces` (breaking change)
- RSpec matcher now accepts a module as the subject via
  `expect(namespace: MyModule).to have_matching_interfaces`
- RSpec shared example now accepts `namespace:` as a keyword argument

### Fixed
- Numbered block parameters (`_1`) replaced with named ones to avoid
  `Style/ItBlockParameter` lint failures on Ruby 3.4

## [0.4.0] - 2026-03-09

### Added
- Strict mode (`strict: true`) for interface comparison: positional
  argument names must match exactly. Available on
  `assert_interfaces_match`, `have_matching_interfaces`, and the
  RSpec shared example. Keyword argument names always matter
  regardless of this setting.
- `assert_duck_types_match` as an alias for `assert_interfaces_match`
- `have_matching_duck_types` as an alias for `have_matching_interfaces`
- `BulkInterfaceChecker` now raises `ArgumentError` when fewer than
  two classes are given

### Fixed
- RSpec shared example was broken on Ruby 3.1 due to proc argument
  destructuring differences between Ruby versions

### Changed
- `ParamsNormalizer` refactored into a factory (`ParamsNormalizer.for(strict:)`)
  with extracted modules: `KeywordNormalizer`, `SequentialNormalizer`,
  `DefaultParamsNormalizer`, `StrictParamsNormalizer`, and
  `NullParamsNormalizer` — all consolidated in a single file
- CI now runs against Ruby 3.1 (minimum) and 3.4 (latest)

## [0.3.2] - 2026-03-07

### Changed
- Move type validation and `TYPES` constant to `MethodInspector`
- Refactor `ParamsNormalizer`: extract `SEQUENTIAL_TYPES` constant
  and `sequentialize_params`, reorder methods for natural reading order
- Introduce `NullParamsNormalizer` as an explicit null object,
  replacing an implicit identity lambda
- Move `MethodInspector`, `ParamsNormalizer`, and `NullParamsNormalizer`
  to the `DuckTyper` namespace; nest `ClassMethodInspector` and
  `InstanceMethodInspector` inside `MethodInspector`
- Use `assoc` to look up method params in `join_signature`
- Inline `inspector` locals throughout `InterfaceChecker`
- Mark `ParamsNormalizer`, `NullParamsNormalizer`, and `MethodInspector`
  as internal (`:nodoc:`)

### Added
- `ParamsNormalizer` test suite
- Test that each differing method appears only once in `failure_message`
- Test that `assert_interfaces_match` passes for matching pairs even
  when another class in the list mismatches

## [0.3.1] - 2026-03-07

### Added
- CHANGELOG

### Changed
- Add `rake ci` task combining StandardRB, Minitest, and RSpec
- Add `check_lockfile` task to catch `Gemfile.lock` drift
- Simplify CI config to a single `rake ci` step
- Remove empty RBS signature file
- Add MIT license to gemspec

## [0.3.0] - 2026-03-07

### Added
- Keyword argument order is now ignored when comparing interfaces —
  `m(a:, b:)` and `m(b:, a:)` are treated as equivalent
- Support for `:nokey` parameter type (`def foo(**nil)`)
- `failure_message` now returns `nil` when interfaces match
- README Limitations section
- Self-referential test verifying `ClassMethodInspector` and
  `InstanceMethodInspector` share compatible interfaces

### Changed
- Improved failure message: "implement compatible interfaces" /
  "method signatures differ"
- Extract `calculate_diff` private method

## [0.2.1] - 2026-03-06

### Changed
- README improvements: Minitest section moved before RSpec,
  partial interface wording clarified

## [0.2.0] - 2026-03-06

### Changed
- Renamed `assert_interface_matches` to `assert_interfaces_match`
  (breaking change)

## [0.1.0] - 2026-03-06

### Added
- Initial release
