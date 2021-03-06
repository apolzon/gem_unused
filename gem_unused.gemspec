# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "gem_unused/version"

Gem::Specification.new do |s|
  s.name        = "gem_unused"
  s.version     = GemUnused::VERSION
  s.authors     = ["Chris Apolzon"]
  s.email       = ["apolzon@gmail.com"]
  s.homepage    = ""
  s.summary     = %q{Clean your gemset!}
  s.description = %q{Removes rvm gemset gems not being used by your project}

  s.rubyforge_project = "gem_unused"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]
  s.required_rubygems_version = ">= 1.8.0"

  s.add_runtime_dependency "bundler", "~> 1.0.0"

  s.add_development_dependency "ruby-debug-pry"
end
