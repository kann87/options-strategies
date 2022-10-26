# frozen_string_literal: true

require_relative "lib/options/strategies/version"

Gem::Specification.new do |spec|
  spec.name = "options-strategies"
  spec.version = Options::Strategies::VERSION
  spec.authors = ["kann87"]
  spec.email = ["kann87@gmail.com"]

  spec.summary = "Options Strategy Builder for NSE F&O"
  spec.description = ""
  spec.homepage = "https://github.com/kann87/options-strategies.git"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 2.3.6"

  spec.metadata["allowed_push_host"] = ""

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/kann87/options-strategies.git"
  spec.metadata["changelog_uri"] = "https://github.com/kann87/options-strategies.git"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(__dir__) do
    `git ls-files -z`.split("\x0").reject do |f|
      (f == __FILE__) || f.match(%r{\A(?:(?:bin|test|spec|features)/|\.(?:git|travis|circleci)|appveyor)})
    end
  end
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]
  spec.add_development_dependency "rspec", "~> 3.11"
  spec.add_development_dependency "rake", "~> 13.0.6"

  # Uncomment to register a new dependency of your gem
  # spec.add_dependency "example-gem", "~> 1.0"

  # For more information and examples about making a new gem, check out our
  # guide at: https://bundler.io/guides/creating_gem.html
end
