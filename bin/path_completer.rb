#!/usr/bin/env ruby
require File.join(File.dirname(__FILE__), 'path_completion')

PathCompletion.config_key = ARGV.shift or raise "Path key needs to be specified"
puts PathCompletion.new(ENV["COMP_LINE"]).matches
exit 0
