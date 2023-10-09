# frozen_string_literal: true

require_relative "lib/rails/pdf/renderer/version"

Gem::Specification.new do |spec|
  spec.name = "rails-pdf-renderer"
  spec.version = RailsPdfRenderer::VERSION
  spec.authors = ["Erik Axel Nielsen"]
  spec.email = ["erikaxel.nielsen@gmail.com"]

  spec.summary = "Create PDFs directly from Rails."
  spec.description = "Helper library to generate PDFs from Rails."
  spec.homepage = "https://github.com/erikaxel/"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 2.6.0"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/erikaxel/"
  spec.metadata["changelog_uri"] = "https://github.com/erikaxel/CHANGELOG.md"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(__dir__) do
    `git ls-files -z`.split("\x0").reject do |f|
      (File.expand_path(f) == __FILE__) ||
        f.start_with?(*%w[bin/ test/ spec/ features/ .git .circleci appveyor Gemfile])
    end
  end
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency 'rails'
  spec.add_development_dependency 'rake'
  spec.add_development_dependency 'rspec'
  spec.add_development_dependency "rspec-rails"
  spec.add_development_dependency 'standard'
end
