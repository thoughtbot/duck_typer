# Changelog

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
