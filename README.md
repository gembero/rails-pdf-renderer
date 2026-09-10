# RailsPdfRenderer

## Ruby support

This gem only supports Ruby versions that are still supported by the Ruby core
team. When a Ruby version reaches end-of-life it is dropped from the CI matrix
and `required_ruby_version` is raised in the next release, which may happen in a
minor version bump.

The currently supported versions are Ruby 3.3, 3.4 and 4.0.

## Installation

Install the gem and add to the application's Gemfile by executing:

    $ bundle add rails-pdf-renderer

## Usage



## Development

The local Ruby version is managed with [mise](https://mise.jdx.dev) and pinned in
`.tool-versions`. Install it once with `mise install`, and run every command through mise so it
uses the pinned Ruby rather than the system one:

    $ mise install
    $ mise exec -- bin/setup

If you have mise activated in your shell (`mise activate`), the `mise exec --` prefix is
unnecessary — the pinned Ruby is already on your `PATH`. The examples below spell it out so
they work either way.

Run the tests with `mise exec -- rake spec`, or `mise exec -- bundle exec rake` for the full
gate (rspec + standardrb) that CI runs. You can also run `mise exec -- bin/console` for an
interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `mise exec -- bundle exec rake install`.

Development happens on Ruby 4.0 even though the gem supports 3.3 and up; CI is what covers
the rest of the matrix.

## Releasing new gems
1. Update version.rb
2. Run `mise exec -- bundle exec rake release` to release a new gem

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/erikaxel/rails-pdf-renderer.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

Initial inspiration and code was influenced by [wicked_pdf](https://github.com/mileszs/wicked_pdf/)