
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "SurfCustomCalabash/version"

Gem::Specification.new do |spec|
  spec.name          = "SurfCustomCalabash"
  spec.version       = SurfCustomCalabash::VERSION
  spec.authors       = ["Alexey Hripunov", "Igor Tolubaev"]
  spec.email         = ["hripunov@surfstudio.ru"]

  spec.summary       = "Custom methods for calabash ios and android"
  spec.description   = "Custom methods for calabash ios and android"
  spec.homepage      = "https://github.com/alexeyhripunov/SurfCustomCalabash"
  spec.license       = "MIT"

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the 'allowed_push_host'
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  if spec.respond_to?(:metadata)
    # spec.metadata["allowed_push_host"] = "http://rubygems.org"

    spec.metadata["homepage_uri"] = spec.homepage
    spec.metadata["source_code_uri"] = "https://github.com/alexeyhripunov/SurfCustomCalabash"
    spec.metadata["changelog_uri"] = "https://github.com/alexeyhripunov/SurfCustomCalabash"
  else
    raise "RubyGems 2.0 or newer is required to protect against " \
      "public gem pushes."
  end

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files         = Dir.chdir(File.expand_path('..', __FILE__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  # spec.bindir        = "exe"
  spec.executables   = ["SurfCustomCalabash"]
  # spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.17"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "minitest", "~> 5.0"
end
