# Contributing

[Bug reports][bugs] and [pull requests][prs] are welcome on GitHub
at https://github.com/thoughtbot/duck_typer.

[bugs]: https://github.com/thoughtbot/duck_typer/issues/new
[prs]: https://github.com/thoughtbot/duck_typer/pulls

Please create a [new discussion][discussion] if you want to share
ideas for new features.

[discussion]: https://github.com/thoughtbot/duck_typer/discussions/new?category=ideas

We love contributions from everyone.
By participating in this project,
you agree to abide by the thoughtbot [code of conduct].

[code of conduct]: https://thoughtbot.com/open-source-code-of-conduct

We expect everyone to follow the code of conduct
anywhere in thoughtbot's project codebases,
issue trackers, chatrooms, and mailing lists.

## Contributing Code

Fork the repo.

Run the setup script.

```
./bin/setup
```

Make sure everything passes:

```
bundle exec rake test
bundle exec standardrb
```

Make your change, with new passing tests.

Push to your fork. Write a [good commit message][commit]. Submit a
pull request.

[commit]: http://tbaggery.com/2008/04/19/a-note-about-git-commit-messages.html

Others will give constructive feedback.
This is a time for discussion and improvements,
and making the necessary changes will be required before we can
merge the contribution.

## Publishing to RubyGems

When the gem is ready to be shared as a formal release, it can be
[published][published] to RubyGems.

[published]: https://guides.rubyonrails.org/plugins.html#publishing-your-gem

1. Bump the version number in `DuckTyper::VERSION`
2. Run `bundle exec rake build`
3. Run `bundle exec rake install`
4. Run `bundle exec rake release`
