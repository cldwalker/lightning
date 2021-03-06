# -*- encoding: utf-8 -*-
require 'rubygems' unless Object.const_defined?(:Gem)
require File.dirname(__FILE__) + "/lib/lightning/version"

Gem::Specification.new do |s|
  s.name        = "lightning"
  s.version     = Lightning::VERSION
  s.authors     = ["Gabriel Horner"]
  s.email       = "gabriel.horner@gmail.com"
  s.homepage    = "http://tagaholic.me/lightning/"
  s.summary = "Lightning is a commandline framework that generates shell functions which wrap around commands to autocomplete and translate full paths by their basenames."
  s.description = "Lightning is a commandline framework that lets users wrap commands with shell functions that are able to refer to any filesystem path by its basename. To achieve this, a group of paths to be translated are defined with shell globs. These shell globs, known as a lightning _bolt_, are then applied to commands to produce functions. In addition to translating basenames to full paths, lightning _functions_ can autocomplete these basenames, resolve conflicts if they have the same name, leave any non-basename arguments untouched, and autocomplete directories above and below a basename. To make bolts shareable between users and functions easier to create, lightning has _generators_. A _generator_ generates filesystem-specific globs for a bolt. Lightning comes with some default generators. Users can make their own generators with generator plugins placed under ~/.lightning/generators/."
  s.required_rubygems_version = ">= 1.3.6"
  s.executables = %w{lightning lightning-complete lightning-translate}
  s.has_rdoc = 'yard'
  s.rdoc_options = ['--title', "Lightning #{Lightning::VERSION} Documentation"]
  s.add_development_dependency 'bacon', '>= 1.1.0'
  s.add_development_dependency 'rr', '>= 1.0'
  s.add_development_dependency 'bacon-bits'
  s.add_development_dependency 'bacon-rr'
  s.files = Dir.glob(%w[{lib,test}/**/*.rb bin/* [A-Z]*.{txt,rdoc} ext/**/*.{rb,c} **/deps.rip]) + %w{Rakefile .gemspec}
  s.files += Dir.glob(['test/*.yml', 'man/*', '.travis.yml'])
  s.extra_rdoc_files = ["README.rdoc", "LICENSE.txt"]
  s.license = 'MIT'
end
