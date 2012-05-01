# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{enotis_pluggable_auth}
  s.version = "0.0.1"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = [%q{Jeff Lunt}]
  s.date = %q{2012-05-01}
  s.description = %q{eNOTIS pluggable auth gem}
  s.email = [%q{jefflunt@gmail.com}]
  s.homepage = %q{}
  s.require_paths = [%q{lib}]
  s.rubygems_version = %q{1.8.9}
  s.summary = %q{eNOTIS pluggable auth gem}

  if s.respond_to? :specification_version then
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<faraday>, ["~> 0.7.6"])
      s.add_runtime_dependency(%q<json>, ["~> 1.6.6"])
      s.add_development_dependency(%q<rspec>, ["~> 2.9"])
      s.add_development_dependency(%q<rake>, ["~> 0.9.2"])
    else
      s.add_dependency(%q<faraday>, ["~> 0.7.6"])
      s.add_dependency(%q<json>, ["~> 1.6.6"])
      s.add_dependency(%q<rspec>, ["~> 2.9"])
      s.add_dependency(%q<rake>, ["~> 0.9.2"])
    end
  else
    s.add_dependency(%q<faraday>, ["~> 0.7.6"])
    s.add_dependency(%q<json>, ["~> 1.6.6"])
    s.add_dependency(%q<rspec>, ["~> 2.9"])
    s.add_dependency(%q<rake>, ["~> 0.9.2"])
  end
end
