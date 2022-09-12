# frozen_string_literal: true

require_relative "lib/rails_graph/version"

Gem::Specification.new do |spec|
  spec.name = "rails_graph"
  spec.version = RailsGraph::VERSION
  spec.authors = ["Ahmad Elassuty"]
  spec.email = ["ahmad.elassuty@gmail.com"]

  spec.summary = "Graph visualization for Rails applications."
  spec.homepage = "https://github.com/ahmad-elassuty/rails_graph"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 2.6.0"

  spec.metadata["rubygems_mfa_required"] = "true"
  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = spec.homepage
  spec.metadata["changelog_uri"] = "#{spec.homepage}/blob/main/CHANGELOG.md"

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

  # Dependencies
  spec.add_dependency "activerecord", ">= 6.0", "< 7.1"
end
