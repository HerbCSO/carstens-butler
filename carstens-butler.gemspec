require_relative 'lib/carstens/butler/version'

Gem::Specification.new do |spec|
  spec.name          = "carstens-butler"
  spec.version       = Carstens::Butler::VERSION
  spec.authors       = ["Carsten Dreesbach"]
  spec.email         = ["carsten.dreesbach@opower.com"]

  spec.summary       = %q{A little web app for interacting with Slack}
  spec.description   = %q{Just what the summary said. ;]}
  spec.homepage      = "https://github.com/HerbCSO/carstens-butler"
  spec.license       = "MIT"
  spec.required_ruby_version = Gem::Requirement.new(">= 3.2")

  spec.metadata["allowed_push_host"] = "https://rubygems.org"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/HerbCSO/carstens-butler"
  spec.metadata["changelog_uri"] = "https://github.com/HerbCSO/carstens-butler/blob/main/CHANGELOG.md"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files         = Dir.chdir(File.expand_path('..', __FILE__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "http"
  spec.add_dependency "sinatra"
  spec.add_dependency "sinatra-contrib"
  spec.add_dependency "thin"
  spec.add_dependency "octokit", ">= 4.25.0" # addresses insecure permissions issue

  spec.add_development_dependency "github_changelog_generator"
  spec.add_development_dependency "pry"
end
