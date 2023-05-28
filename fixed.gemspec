# frozen_string_literal: true

require "./lib/fixed/version"

Gem::Specification.new do |spec|
  spec.name = "fixed"
  spec.version = Fixed::VERSION
  spec.authors = ["Adrian Kuhn"]
  spec.email = ["akuhn@iam.unibe.ch"]
  spec.license = "MIT"

  spec.summary = "Fixed-point numbers with 18-digit precision."
  spec.homepage = "https://github.com/akuhn/fixed"
  spec.required_ruby_version = ">= 1.9.3"

  if spec.respond_to? :metadata
    spec.metadata["homepage_uri"] = spec.homepage
    spec.metadata['source_code_uri'] = "https://github.com/akuhn/fixed"
    spec.metadata['changelog_uri'] = "https://github.com/akuhn/fixed/blob/master/lib/fixed/version.rb"
  end

  spec.require_paths = ["lib"]
  spec.files = %w{
    README.md
    lib/fixed.rb
    lib/fixed/version.rb
  }

  # For more information and examples about making a new gem, check out our
  # guide at: https://bundler.io/guides/creating_gem.html
end
