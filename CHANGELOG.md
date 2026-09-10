# Change Log
All notable changes to this project will be documented in this file.
This project adheres to [Semantic Versioning](http://semver.org/).

## [Unreleased]
### Fixes
- Declare `activesupport` (>= 7.0) as a runtime dependency. It is required at
  load time by `RailsPdfRenderer::Config`, but was previously only pulled in
  through the host application.

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