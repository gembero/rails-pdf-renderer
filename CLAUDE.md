# rails-pdf-renderer

## Ruby toolchain

The local Ruby version is managed by [mise](https://mise.jdx.dev) and pinned in `.tool-versions`
(Ruby 4.0). The gem itself supports Ruby 3.3+; CI covers 3.3, 3.4 and 4.0.

**Always run Ruby commands through `mise exec --`** so they use the pinned Ruby instead of
the system Ruby:

```bash
mise exec -- bundle install
mise exec -- bundle exec rake        # the gate: rspec + standardrb
mise exec -- bundle exec rspec
mise exec -- standardrb --fix
```

If `mise install` hasn't been run in a fresh checkout, run it first.
