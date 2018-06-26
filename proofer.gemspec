# -*- encoding: utf-8 -*-
$LOAD_PATH.push File.expand_path('../lib', __FILE__)
require 'proofer/version'

Gem::Specification.new do |s|
  s.name = 'proofer'
  s.version = Proofer::VERSION
  s.platform = Gem::Platform::RUBY
  s.authors = ['Peter Karman <peter.karman@gsa.gov>']
  s.email = 'peter.karman@gsa.gov'
  s.homepage = 'https://github.com/18F/identity-proofer-gem'
  s.summary = 'Identity Proofer'
  s.description = 'Identity Proofer for Ruby'
  s.date = Time.now.utc.strftime('%Y-%m-%d')
  s.files = Dir.glob('app/**/*') + Dir.glob('lib/**/*') + [
    'LICENSE.md',
    'README.md',
    'Gemfile',
    'proofer.gemspec'
  ]
  s.license = 'LICENSE'
  s.test_files = `git ls-files -- {test,spec,features}/*`.split('\n')
  s.executables = `git ls-files -- bin/*`.split('\n').map { |f| File.basename(f) }
  s.require_paths = ['lib']
  s.rdoc_options = ['--charset=UTF-8']

  s.required_ruby_version = '>= 2.3.0'

  s.add_development_dependency('bundler')
  s.add_development_dependency('rake')
  s.add_development_dependency('reek')
  s.add_development_dependency('rspec')
  s.add_development_dependency('rubocop')
end
