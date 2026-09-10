# CLAUDE.md

Guidance for Claude Code working in this repository.

## What this gem is

`rails-pdf-renderer` is a Rails gem that renders a controller view to HTML and then
POSTs that HTML to an **external PDF rendering service** (a headless-Chrome-style
server), which returns the PDF bytes. It does *not* shell out to a local binary.
This is the main architectural difference from [wicked_pdf](https://github.com/mileszs/wicked_pdf/),
from which much of the asset-handling code was adapted.

Usage in an app looks like `render pdf: "filename", template: "..."` — the gem
intercepts `render`/`render_to_string` when the options hash contains a `:pdf` key.

## Commands

```bash
bin/setup                # bundle install
bundle exec rake         # default task: rspec + standardrb (what CI runs)
bundle exec rake spec    # tests only
bundle exec standardrb   # lint only; add --fix to autocorrect
bin/console              # IRB with the gem loaded
```

CI (`.github/workflows/main.yml`) runs `bundle exec rake` on Ruby 3.2.2 only,
even though the gemspec declares `required_ruby_version >= 2.4.0`. Avoid syntax
newer than Ruby 2.4 in `lib/` (no `&.`-era-only concerns, but no pattern matching,
no endless methods, no hash shorthand) — CI will not catch violations.

## Code layout

All code lives under `lib/rails/pdf/renderer/`, namespaced under the top-level
**class** `RailsPdfRenderer` (a class, not a module — `class RailsPdfRenderer` is
required when reopening it).

- `railtie.rb` — wiring. Prepends `ActionControllerHelper` onto `ActionController::Base`
  and includes `ActionViewHelper` into views via `ActiveSupport.on_load`. Also
  registers the `application/pdf` MIME type. Everything is guarded by
  `if defined?(Rails.env)` so the gem can be required outside Rails.
- `action_controller_helper.rb` — the `render`/`render_to_string` overrides,
  `make_pdf`, and `pdf_from_server` (the HTTP call to the PDF service).
- `action_view_helper.rb` — the bulk of the code: `pdf_asset_path`,
  `pdf_stylesheet_link_tag`, `pdf_image_tag`, `pdf_*_base64`, etc. These inline
  assets into the HTML so the remote renderer can resolve them. Supports Sprockets,
  Propshaft, and Webpacker/Shakapacker; each has its own branch in `find_asset`
  and `webpacker_source_url`. Touching one branch usually means checking the others.
- `config.rb` — configuration, built on `class_attribute`.
- `error.rb` — `RailsPdfRenderer::Error`, wraps the failed `Net::HTTP` response.
- `path_helper.rb`, `version.rb`.

## Things that will bite you

- **Config is global class state.** `Config` uses `class_attribute`, and
  `RailsPdfRenderer.configuration` memoizes a single instance, so assigning a
  value mutates the class default for the whole process. Tests that change
  configuration must restore it.
- **`pdf_server_params` unconditionally reads `options[:margin][:top]`** and the
  other margin keys. The default `margin` hash comes from `Config.default_options`,
  which is merged in by `render`. Any code path that builds options without that
  merge will `NoMethodError` on `nil`.
- **`auth_key` is base64-encoded before being sent** as `Authorization: Bearer <base64>`.
  A missing `auth_key` raises a plain `RuntimeError`, not `RailsPdfRenderer::Error`.
- The controller helper's `make_pdf` calls `render_to_string` recursively — the
  override checks for the `:pdf` key to avoid infinite recursion, so never leave
  `:pdf` in the options hash passed downward (`make_pdf` deletes it explicitly).
- Assets read from disk or over HTTP are `force_encoding('UTF-8')`'d — this was a
  deliberate fix for Propshaft (see CHANGELOG 0.3.0), don't remove it.
- `raise_on_missing_assets` defaults to `true`, so a missing stylesheet or image
  raises rather than silently rendering a blank PDF.

## Style

`standard` (standardrb) is the linter and part of the default rake task, but
existing code in `action_controller_helper.rb` and `action_view_helper.rb` uses
hashrocket syntax and single quotes inherited from wicked_pdf. Match the
surrounding file rather than reformatting; run `standardrb` before committing and
keep unrelated formatting churn out of diffs.

## Releasing

1. Bump `VERSION` in `lib/rails/pdf/renderer/version.rb`.
2. Add an entry to `CHANGELOG.md`.
3. `bundle exec rake release` (tags, pushes, publishes to rubygems.org).
