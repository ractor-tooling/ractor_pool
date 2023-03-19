# frozen_string_literal: true

require_relative "lib/ractor_pool/version"

Gem::Specification.new do |spec|
  spec.name = "ractor_pool"
  spec.version = RactorPool::VERSION

  spec.authors = ["Bill Tihen"]
  spec.email = ["btihen@gmail.com"]

  spec.summary = "ractor pools to easily parallelize ruby codeblocks."
  spec.description = "parallelize ruby code blocks using various type of booling."
  spec.homepage = "https://github.com/ractor_tools/ractor_pool"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 3.2.0"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/ractor_tools/ractor_pool"
  spec.metadata["changelog_uri"] = "https://github.com/ractor_tools/ractor_pool/CHANGELOG.md"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(__dir__) do
    `git ls-files -z`.split("\x0").reject do |f|
      (File.expand_path(f) == __FILE__) || f.match(%r{\A(?:(?:bin|test|spec|features)/|\.(?:git|circleci)|appveyor)})
    end
  end
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  # Uncomment to register a new dependency of your gem
  # spec.add_dependency "example-gem", '~> 1.0'
  # spec.add_dependency 'ractor-tvar', '~> 0.4.0'

  spec.add_development_dependency "mutant", "~> 0.11.18"
  spec.add_development_dependency "pry"
  spec.add_development_dependency "rspec", "~> 3.12.0"
  spec.add_development_dependency 'rubocop', '~> 1.48.1'
  spec.add_development_dependency 'rubocop-performance', '~> 1.16.0'
  spec.add_development_dependency 'rubocop-rake', '~> 0.6.0'
  spec.add_development_dependency 'rubocop-rspec', '~> 2.19.0'
  spec.add_development_dependency 'simplecov', '~> 0.22.0'

  # spec.authors = ["William Tihen"]
  # spec.email = ["william.tihen@garaio-rem.ch"]

  # spec.summary = "TODO: Write a short summary, because RubyGems requires one."
  # spec.description = "TODO: Write a longer description or delete this line."
  # spec.homepage = "TODO: Put your gem's website or public repo URL here."
  # spec.license = "MIT"
  # spec.required_ruby_version = ">= 2.6.0"

  # spec.metadata["allowed_push_host"] = "TODO: Set to your gem server 'https://example.com'"

  # spec.metadata["homepage_uri"] = spec.homepage
  # spec.metadata["source_code_uri"] = "TODO: Put your gem's public repo URL here."
  # spec.metadata["changelog_uri"] = "TODO: Put your gem's CHANGELOG.md URL here."

  # # Specify which files should be added to the gem when it is released.
  # # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  # spec.files = Dir.chdir(__dir__) do
  #   `git ls-files -z`.split("\x0").reject do |f|
  #     (File.expand_path(f) == __FILE__) || f.match(%r{\A(?:(?:bin|test|spec|features)/|\.(?:git|circleci)|appveyor)})
  #   end
  # end
  # spec.bindir = "exe"
  # spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  # spec.require_paths = ["lib"]

  # Uncomment to register a new dependency of your gem
  # spec.add_dependency "example-gem", "~> 1.0"

  # For more information and examples about making a new gem, check out our
  # guide at: https://bundler.io/guides/creating_gem.html
end
