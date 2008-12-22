#!/usr/bin/env ruby

# == Description
# Used by path completion functions to return first possible full path which matches the given basename under the specified directories.
# Directories can be specified after the basename:
#   $0 dir.rb ~/apps ~/temp
#
# Or in the config file path_completions.yml and then reference the key of config hash:
#   $0 -k code dir.rb
#
# Warning: Basenames that occur in multiple directories will return the first directory found.

require 'optparse'
require 'yaml'

def parse_argv
  options = {}
	ARGV.options do |opts|
	  script_name = File.basename($0)
	  opts.banner = "Usage: #{script_name} [options] basename [directories]"

	 opts.separator ""

	opts.on("-k", "--key=key", String, "sets directories to key found in path_completions.yml") {|options[:key]|}
	 opts.on("-h", "--help",
		  "Show this help message.") { puts opts; exit }

	  opts.parse!
	end
  options
end

def paths_for_basename(basename, dirs)
  files = []
  dirs.each do |d|
    Dir.entries(d).each do |f|
      files.push(File.join(d,f)) if f == basename
    end
  end
  files.uniq
end

options = parse_argv()
basename = ARGV.shift
config_yaml_file = File.join(File.dirname(__FILE__), "path_completions.yml")
dirs = options[:key] ? YAML::load(File.new(config_yaml_file))[options[:key]] : ARGV

if dirs.nil? || basename.nil?
  puts "No directories given to look under" if dirs.nil?
  puts "No basename given" if basename.nil?
  exit
end
puts paths_for_basename(basename,dirs)[0] || ''
