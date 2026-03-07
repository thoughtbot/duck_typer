# CLAUDE.md

## Release

- Before writing to `CHANGELOG.md`, pull from `main` and do a
  detailed analysis of all commits since the last tag (e.g.
  `git log <last-tag>..HEAD`).
- Based on the analysis, determine the next version number: bump
  the patch version for internal changes or bug fixes, the minor
  version for new features, and the major version for breaking
  changes. Confirm the version number with the programmer before
  proceeding.
- Update `CHANGELOG.md` with the new version and a summary of
  changes.
- After releasing, delete the generated `.gem` files from the root
  directory — they are not committed and should not linger.

## Ruby version

For now, use the minimum required Ruby version for development —
this ensures the gem works for everyone who meets that requirement.

When updating the minimum required Ruby version, update it in all
of these places:

- `.ruby-version`
- `.tool-versions`
- `duck_typer.gemspec` (`spec.required_ruby_version`)
- `.github/workflows/ci.yml` (`ruby-version`)

## Commands

- `bundle exec rake test` — run Minitest and RSpec suites
- `bundle exec rake minitest` — run Minitest suite only
- `bundle exec rake ci` — run tests, linting, and lockfile drift check
  (always run before pushing)
- `bundle exec standardrb` — lint

## Tests

- **Minitest is the default test suite.** Test files live in `test/`.
- **RSpec is only for testing RSpec-specific functionality.**
  Spec files live in `spec/`.
- New tests belong in `test/` unless they exercise the RSpec
  integration.
- When two or more classes are interchangeably used (e.g. a class
  and its null object), write an interface test using the gem's own
  `assert_interfaces_match` (include `DuckTyper::Minitest`).
- When testing a transformation (e.g. `ParamsNormalizer`), always
  include a mixed test that exercises all cases together, in addition
  to focused tests for each case.

## Code style

- Markdown files should be kept at 70 columns.
- File paths must match the Ruby namespace: `DuckTyper::Foo` lives
  in `lib/duck_typer/foo.rb`, not under a subdirectory of another
  class.
- Classes are only nested inside another class when they are
  intrinsically part of it (e.g. `InterfaceChecker::Result`).
  Otherwise they belong at the `DuckTyper` root level.
- Methods are defined in natural reading order: callers before
  callees.
- Leave a blank line before the return value in multi-line methods.
- Extract constants for inline literals used in conditionals.
- Private methods mirror each other when they share a common role
  (e.g. `sort_keyword_params` / `sequentialize_params`).
- Use `params` instead of `parameters` in names (e.g. method names,
  variable names).
