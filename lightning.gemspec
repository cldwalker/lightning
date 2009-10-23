# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{lightning}
  s.version = "0.2.1"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Gabriel Horner"]
  s.date = %q{2009-10-23}
  s.description = %q{Lightning creates shell commands that each autocomplete to a configured group of files and directories. Autocompleting is quick since you only need to type the basename and can even use regex completion.}
  s.email = %q{gabriel.horner@gmail.com}
  s.executables = ["lightning-complete", "lightning-full_path", "lightning-install"]
  s.extra_rdoc_files = [
    "LICENSE.txt",
    "README.rdoc"
  ]
  s.files = [
    "CHANGELOG.rdoc",
    "LICENSE.txt",
    "README.rdoc",
    "Rakefile",
    "VERSION.yml",
    "bin/lightning-complete",
    "bin/lightning-full_path",
    "bin/lightning-install",
    "lib/lightning.rb",
    "lib/lightning/bolt.rb",
    "lib/lightning/bolts.rb",
    "lib/lightning/commands.rb",
    "lib/lightning/completion.rb",
    "lib/lightning/completion_map.rb",
    "lib/lightning/config.rb",
    "lib/lightning/generator.rb",
    "lightning.yml.example",
    "lightning_completions.example",
    "test/bolt_test.rb",
    "test/completion_map_test.rb",
    "test/completion_test.rb",
    "test/config_test.rb",
    "test/lightning.yml",
    "test/lightning_test.rb",
    "test/test_helper.rb"
  ]
  s.homepage = %q{http://github.com/cldwalker/lightning}
  s.rdoc_options = ["--charset=UTF-8"]
  s.require_paths = ["lib"]
  s.rubyforge_project = %q{tagaholic}
  s.rubygems_version = %q{1.3.5}
  s.summary = %q{Path completions for your shell that will let you navigate like lightning.}
  s.test_files = [
    "test/bolt_test.rb",
    "test/completion_map_test.rb",
    "test/completion_test.rb",
    "test/config_test.rb",
    "test/lightning_test.rb",
    "test/test_helper.rb"
  ]

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 3

    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
    else
    end
  else
  end
end
