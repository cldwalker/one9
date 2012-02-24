# -*- encoding: utf-8 -*-
require 'rubygems' unless Object.const_defined?(:Gem)
require File.dirname(__FILE__) + "/lib/one9/version"

Gem::Specification.new do |s|
  s.name        = "one9"
  s.version     = One9::VERSION
  s.authors     = ["Gabriel Horner"]
  s.email       = "gabriel.horner@gmail.com"
  s.homepage    = "http://github.com/cldwalker/one9"
  s.summary = "commandline tool to convert your 1.8 code to ruby 1.9.2"
  s.description =  "one9 is a commandline tool to help convert your ruby 1.8.7 code to 1.9.2.  It works by spying on your tests and detecting 1.9 changes. Once your test suite finishes, one9 prints a report listing the exact locations of methods that have changed in 1.9. To make the transition even easier, one9 can open this list in an editor. So what's your excuse for not upgrading to 1.9.2? ;)"
  s.required_rubygems_version = ">= 1.3.6"
  s.executables = ['one9']
  s.files = Dir.glob(%w[{lib,test}/**/*.rb bin/* [A-Z]*.{txt,rdoc} ext/**/*.{rb,c} **/deps.rip]) + %w{Rakefile .gemspec .travis.yml}
  s.files += Dir.glob('features/**/*.{rb,feature}')
  s.extra_rdoc_files = ["README.rdoc", "LICENSE.txt"]
  s.add_dependency 'hirb', '>= 0.4.0'
  s.add_development_dependency 'aruba', '~> 0.3.2'
  s.add_development_dependency 'rake', '~> 0.9.2'
  s.license = 'MIT'
end
