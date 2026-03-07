# frozen_string_literal: true

require_relative "lib/duck_typer/version"

Gem::Specification.new do |spec|
  spec.name = "duck_typer"
  spec.version = DuckTyper::VERSION
  spec.authors = ["Thiago A. Silva"]
  spec.email = ["thiagoaraujos@gmail.com"]

  spec.summary = "Enforce duck-typed interfaces in Ruby through your test suite."
  spec.homepage = "https://github.com/thoughtbot/duck_typer"
  spec.required_ruby_version = ">= 3.1.0"

  spec.license = "MIT"
  spec.metadata["allowed_push_host"] = "https://rubygems.org"

  spec.metadata["source_code_uri"] = "https://github.com/thoughtbot/duck_typer"
  spec.metadata["changelog_uri"] = "https://github.com/thoughtbot/duck_typer/blob/main/CHANGELOG.md"
  spec.metadata["rubygems_mfa_required"] = "true"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  gemspec = File.basename(__FILE__)
  spec.files = IO.popen(%w[git ls-files -z], chdir: __dir__, err: IO::NULL) do |ls|
    ls.readlines("\x0", chomp: true).reject do |f|
      (f == gemspec) ||
        f.start_with?(*%w[assets/ bin/ test/ spec/ features/ .git appveyor Gemfile])
    end
  end
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  # For more information and examples about making a new gem, check out our
  # guide at: https://bundler.io/guides/creating_gem.html
end
