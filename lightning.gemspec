# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{lightning}
  s.version = "0.2.1"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Gabriel Horner"]
  s.date = %q{2009-12-16}
  s.description = %q{Lightning creates shell commands that autocomplete and alias configured group of files and directories. Autocompleting is quick since you only need to type the basename.}
  s.email = %q{gabriel.horner@gmail.com}
  s.executables = ["lightning-complete", "lightning-translate", "lightning-build", "lightning-generate"]
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
    "bin/lightning-build",
    "bin/lightning-complete",
    "bin/lightning-generate",
    "bin/lightning-translate",
    "lib/lightning.rb",
    "lib/lightning/bolt.rb",
    "lib/lightning/builder.rb",
    "lib/lightning/cli.rb",
    "lib/lightning/cli_commands.rb",
    "lib/lightning/command.rb",
    "lib/lightning/completion.rb",
    "lib/lightning/completion_map.rb",
    "lib/lightning/config.rb",
    "lib/lightning/generator.rb",
    "lib/lightning/generators.rb",
    "lib/lightning/util.rb",
    "lightning.yml.example",
    "test/bolt_test.rb",
    "test/builder_test.rb",
    "test/cli_test.rb",
    "test/command_test.rb",
    "test/completion_map_test.rb",
    "test/completion_test.rb",
    "test/config_test.rb",
    "test/generator_test.rb",
    "test/lightning.yml",
    "test/test_helper.rb"
  ]
  s.homepage = %q{http://github.com/cldwalker/lightning}
  s.rdoc_options = ["--charset=UTF-8"]
  s.require_paths = ["lib"]
  s.rubyforge_project = %q{tagaholic}
  s.rubygems_version = %q{1.3.5}
  s.summary = %q{Autocomplete paths and execute commands at the speed of light-ning.}
  s.test_files = [
    "test/bolt_test.rb",
    "test/builder_test.rb",
    "test/cli_test.rb",
    "test/command_test.rb",
    "test/completion_map_test.rb",
    "test/completion_test.rb",
    "test/config_test.rb",
    "test/generator_test.rb",
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
