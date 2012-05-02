# -*- encoding: utf-8 -*-
require File.expand_path('../lib/enotis_pluggable_auth/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["Jeff Lunt"]
  gem.email         = ["jefflunt@gmail.com"]
  gem.description   = %q{eNOTIS pluggable auth gem}
  gem.summary       = %q{eNOTIS pluggable auth gem}
  gem.homepage      = ""

  gem.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  gem.files         = `git ls-files`.split("\n")
  gem.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  gem.name          = "enotis_pluggable_auth"
  gem.require_paths = ["lib"]
  gem.version       = EnotisPluggableAuth::VERSION
  
  gem.add_dependency 'faraday', '~> 0.7.6'
  gem.add_dependency 'json', '~> 1.6.6'
  gem.add_dependency 'jruby-openssl', '~> 0.7.6.1'

  gem.add_development_dependency 'rspec', '~> 2.9'
  gem.add_development_dependency 'rake', '~> 0.9.2'
end
