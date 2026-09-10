---
name: release
description: Cut a new version of the rails-pdf-renderer gem — bump the version, update the changelog, and publish to rubygems.org. Use when releasing a new version or bumping the gem version.
---

# Release Skill

## When to use
Use this skill when:
- The user asks to cut, ship, or publish a release
- The user asks to bump the gem version

## Before you start

Check that the last release actually shipped:

```bash
git tag                                   # tags are v-prefixed: v0.4.1
cat lib/rails/pdf/renderer/version.rb     # VERSION = "0.4.2"
```

If `version.rb` is ahead of the newest tag, a previous version was committed but never
released. Ask the user whether to release that version as-is or to bump past it — don't
silently skip it.

Also confirm you're releasing from `main` and that it's up to date with `origin/main`.

## Steps

1. **Bump the version** in `lib/rails/pdf/renderer/version.rb`. The gemspec reads
   `RailsPdfRenderer::VERSION` from this file — it's the single source of truth. Follow
   semver: patch for fixes, minor for backwards-compatible features, major for breaking
   changes.

2. **Add a `CHANGELOG.md` entry.** This step is not optional — the changelog was skipped
   for the entire 0.4.x line and is stale as a result. Match the existing format:

   ```markdown
   ## [0.5.0]
   ### New Features
   - Description of the feature

   ### Fixes
   - Description of the fix
   ```

   Newest version goes at the top, directly under the header block. Use `### New Features`
   and `### Fixes` sections with dash bullets; include only the sections that apply.

3. **Run the gate**: `bundle exec rake` (rspec + standardrb). It must be green before you
   release. CI runs this on Ruby 3.2, 3.3 and 3.4.

4. **Commit** the version bump and changelog together, with the version as the subject
   prefix (see the `commit` skill for the general rules — no AI attribution, present tense):

   ```
   0.5.0 Add support for custom page sizes
   ```

   A bare version subject (`0.4.0`) is acceptable when the release has no single headline
   change, but a short description is better.

5. **Publish**: `bundle exec rake release`. This comes from `bundler/gem_tasks` and will:
   - create the `v0.5.0` git tag
   - push the commit and tag to `origin`
   - build the gem and push it to rubygems.org

   It needs rubygems credentials and it is not reversible — a published version cannot be
   replaced, only yanked. Confirm with the user before running it.

## Notes

- `Gemfile.lock` is gitignored, so there's no lockfile to update.
- `bundle exec rake build` produces the gem locally under `pkg/` without publishing —
  useful for a dry run.
