# frozen_string_literal: true

$LOAD_PATH.push File.expand_path('lib', __dir__)

require 'dubai/version'

Gem::Specification.new do |s|
  s.name        = 'dubai'
  s.authors     = ['Mattt']
  s.email       = 'mattt@me.com'
  s.license     = 'MIT'
  s.homepage    = 'http://nomad-cli.com'
  s.version     = Dubai::VERSION
  s.platform    = Gem::Platform::RUBY
  s.summary     = 'Dubai'
  s.description = 'Passbook pass generation and preview.'

  s.add_dependency 'commander', '~> 4.1'
  s.add_dependency 'json'
  s.add_dependency 'rubyzip', '~> 1.0'
  s.add_dependency 'sinatra', ['>= 1.3', '< 2.0.0']
  s.add_dependency 'terminal-table', '~> 1.4'

  s.add_development_dependency 'rack-test'
  s.add_development_dependency 'rake'
  s.add_development_dependency 'rspec'
  s.add_development_dependency 'simplecov'

  s.files         = Dir['./**/*'].reject { |file| file =~ %r{\./(bin|log|pkg|script|spec|test|vendor)} }
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map { |f| File.basename(f) }
  s.require_paths = ['lib']
end
