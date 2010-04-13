require 'rake'
begin
  require 'rcov/rcovtask'

  Rcov::RcovTask.new do |t|
    t.libs << 'test'
    t.test_files = FileList['test/**/*_test.rb']
    t.rcov_opts = ["-T -x '/Library/Ruby/*'"]
    t.verbose = true
  end
rescue LoadError
end

begin
  require 'jeweler'
  require File.dirname(__FILE__) + "/lib/lightning/version"

  Jeweler::Tasks.new do |s|
    s.name = "lightning"
    s.version = Lightning::VERSION
    s.executables = ['lightning', 'lightning-complete', 'lightning-translate']
    s.summary = "Lightning is a commandline framework that generates shell functions which wrap around commands to autocomplete and translate full paths by their basenames."
    s.description = "Lightning is a commandline framework that lets users wrap commands with shell functions that are able to refer to any filesystem path by its basename. To achieve this, a group of paths to be translated are defined with shell globs. These shell globs, known as a lightning _bolt_, are then applied to commands to produce functions. In addition to translating basenames to full paths, lightning _functions_ can autocomplete these basenames, resolve conflicts if they have the same name, leave any non-basename arguments untouched, and autocomplete directories above and below a basename."
    s.email = "gabriel.horner@gmail.com"
    s.homepage = "http://tagaholic.me/lightning"
    s.authors = ["Gabriel Horner"]
    s.files =  FileList["CHANGELOG.rdoc", "Rakefile","README.rdoc", "LICENSE.txt", "{bin,lib,test,man}/**/*"]
    s.has_rdoc = 'yard'
    s.rdoc_options = ['--title', "Lightning #{Lightning::VERSION} Documentation"]
    s.rubyforge_project = 'tagaholic'
    s.extra_rdoc_files = ["README.rdoc", "LICENSE.txt"]
  end

rescue LoadError
  puts "Jeweler not available. Install it for jeweler-related tasks with: sudo gem install technicalpickles-jeweler -s http://gems.github.com"
end

task :default => :test

desc 'Run specs with unit test style output'
task :test do |t|
  sh 'bacon -q -Ilib test/*_test.rb'
end
