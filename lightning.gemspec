# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{lightning}
  s.version = "0.1.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Gabriel Horner"]
  s.date = %q{2009-01-13}
  s.description = %q{Path completions for your shell that will let you navigate like lightning.}
  s.email = %q{gabriel.horner@gmail.com}
  s.executables = ["lightning-complete", "lightning-full_path", "lightning-install"]
  s.extra_rdoc_files = ["README.markdown", "LICENSE.txt"]
  s.files = ["lightning_completions.example", "lightning.yml.example", "README.markdown", "LICENSE.txt", "bin/lightning-complete", "bin/lightning-full_path", "bin/lightning-install", "lib/lightning", "lib/lightning/completion.rb", "lib/lightning/config.rb", "lib/lightning/core_extensions.rb", "lib/lightning/entry_hash.rb", "lib/lightning/generator.rb", "lib/lightning.rb"]
  s.has_rdoc = true
  s.homepage = %q{http://github.com/cldwalker/lightning}
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.3.1}
  s.summary = %q{Path completions for your shell that will let you navigate like lightning.}

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 2

    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
    else
    end
  else
  end
end
