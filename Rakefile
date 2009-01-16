require 'rake'
require 'rake/testtask'
require 'rake/rdoctask'
begin
  require 'rcov/rcovtask'

  Rcov::RcovTask.new do |t|
    t.libs << 'test'
    t.test_files = FileList['test/**/*_test.rb']
    t.rcov_opts = ["-T -x '/Library/Ruby/*'"]
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
    s.homepage = "http://github.com/cldwalker/lightning"
    s.description = "Path completions for your shell that will let you navigate like lightning."
    s.authors = ["Gabriel Horner"]
    s.files =  FileList["lightning_completions.example", "lightning.yml.example","README.markdown", "LICENSE.txt", "{bin,lib,test}/**/*"]
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

namespace :dev do
  desc "Generates completion, modifies it for local development"
  task :reload=>:generate_completions do
    file = 'lightning_completions'
    string = File.read(file)
    string.sub!(/^LBIN_PATH/,'#LBIN_PATH')
    string.sub!(/^#LBIN_PATH/,'LBIN_PATH')
    File.open(file,'w') {|f| f.write(string) }
  end

  desc "Generates local completion file to be sourced by your shell"
  task :generate_completions do
    $:.unshift 'lib'
    require 'lightning'
    Lightning::Generator.generate_completions 'lightning_completions'
  end
end

task :default => :test
