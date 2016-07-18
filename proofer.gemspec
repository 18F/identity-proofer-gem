# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "proofer/version"

Gem::Specification.new do |s|
  s.name = %q{proofer}
  s.version = Proofer::VERSION
  s.platform = Gem::Platform::RUBY
  s.authors = ["Peter Karman <peter.karman@gsa.gov>"]
  s.email = %q{peter.karman@gsa.gov}
  s.homepage = %q{http://github.com/18F/identity-proofer-gem}
  s.summary = %q{Identity Proofer}
  s.description = %q{Identity Proofer for Ruby}
  s.date = Time.now.utc.strftime("%Y-%m-%d")
  s.files = Dir.glob("app/**/*") + Dir.glob("lib/**/*") + [
     "LICENSE.md",
     "README.md",
     "Gemfile",
     "proofer.gemspec"
  ]
  s.license = "LICENSE"
  s.test_files = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]
  s.rdoc_options = ["--charset=UTF-8"]

  s.add_dependency('dotenv')

  s.add_development_dependency('bundler')
  s.add_development_dependency('rspec')
  s.add_development_dependency('rake')
end
