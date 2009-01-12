require 'rake'
require 'rake/testtask'
require 'rake/rdoctask'
begin
  require 'rcov/rcovtask'

  Rcov::RcovTask.new do |t|
    t.libs << 'test'
    t.test_files = FileList['test/**/*_test.rb']
    t.verbose = true
  end
rescue LoadError
  puts "Rcov not available. Install it for rcov-related tasks with: sudo gem install rcov"
end

begin
  require 'jeweler'
  Jeweler::Tasks.new do |s|
    s.name = "lightning"
    s.executables = ["lightning-complete", "lightning-full_path", "lightning-install"]
    s.summary = "Path completions for your shell that will let you navigate like lightning."
    s.email = "gabriel.horner@gmail.com"
    s.homepage = "http://github.com/cldwalker/test"
    s.description = "Path completions for your shell that will let you navigate like lightning."
    s.authors = ["Gabriel Horner"]
    s.files =  FileList["[A-Za-z]*", "{bin,lib,test}/**/*"]
    s.has_rdoc = true
    s.extra_rdoc_files = ["README.markdown", "LICENSE.txt"]
  end

rescue LoadError
  puts "Jeweler not available. Install it for jeweler-related tasks with: sudo gem install technicalpickles-jeweler -s http://gems.github.com"
end

Rake::TestTask.new do |t|
  t.libs << 'lib'
  t.pattern = 'test/**/*_test.rb'
  t.verbose = false
end

Rake::RDocTask.new do |rdoc|
  rdoc.rdoc_dir = 'rdoc'
  rdoc.title    = 'test'
  rdoc.options << '--line-numbers' << '--inline-source'
  rdoc.rdoc_files.include('README*')
  rdoc.rdoc_files.include('lib/**/*.rb')
end

desc "Generates completion file to be sourced by your shell"
task :generate_completions do
  $:.unshift 'lib'
  require 'lightning'
  Lightning::Generator.generate_completions
end

task :default => :test
