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
    s.summary = "Autocomplete paths and execute commands at the speed of light-ning."
    s.description = "Lightning creates shell commands that autocomplete and alias configured group of files and directories. Autocompleting is quick since you only need to type the basename."
    s.email = "gabriel.horner@gmail.com"
    s.homepage = "http://github.com/cldwalker/lightning"
    s.authors = ["Gabriel Horner"]
    s.files =  FileList["CHANGELOG.rdoc", "Rakefile", "lightning.yml.example","README.rdoc", "LICENSE.txt", "{bin,lib,test}/**/*"]
    s.has_rdoc = true
    s.rubyforge_project = 'tagaholic'
    s.extra_rdoc_files = ["README.rdoc", "LICENSE.txt"]
  end

rescue LoadError
  puts "Jeweler not available. Install it for jeweler-related tasks with: sudo gem install technicalpickles-jeweler -s http://gems.github.com"
end

task :default => :test

desc 'Run specs with unit test style output'
task :test do |t|
  sh 'bacon -q test/*_test.rb'
end
