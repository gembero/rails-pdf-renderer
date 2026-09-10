# Change Log
All notable changes to this project will be documented in this file.
This project adheres to [Semantic Versioning](http://semver.org/).

## [Unreleased]
### New Features
- Added the `html:` option for already-rendered HTML. The string is sent to the PDF
  service verbatim and is never compiled as a template, so `<%= %>` in the content
  cannot execute as Ruby on the server. `layout:`, `locals:`, `assigns:`, `formats:`
  and `handlers:` do not apply to `html:`, and passing both `html:` and `inline:`
  raises `ArgumentError`.
- `type:` is now forwarded to ActionView when rendering `inline:` templates, so a
  non-ERB handler can be used (for example `type: :raw` or `type: :haml`).
- Documented `inline:` (an ERB template) versus `html:` (finished HTML) in the README.

### Fixes
- Declare `activesupport` (>= 7.0) as a runtime dependency. It is required at
  load time by `RailsPdfRenderer::Config`, but was previously only pulled in
  through the host application.
- `status:` is now forwarded to the response for both PDF and `show_as_html:` renders.
  It was previously accepted and silently ignored, so those responses always returned 200.
- `RailsPdfRenderer::ActionControllerHelper` now requires the standard library and
  ActiveSupport extensions it uses instead of relying on the host application.

### Breaking changes
- Dropped support for end-of-life Ruby versions. `required_ruby_version` is now
  `>= 3.3.0`. Only Ruby versions still supported by the Ruby core team are
  supported (currently 3.3, 3.4 and 4.0).

## [0.3.0]
### Fixes
Fix Propshaft encoding issue

## [0.2.0]
### Fixes
- Removed hardcoded URL
- Removed unused helper methods

## [0.1.0]
### New Features
- Initial version