#!/usr/bin/env ruby

require 'rubygems'
$:.unshift File.join(File.dirname(__FILE__), '..', 'lib')
require 'lightning'

key = ARGV.shift or raise "Path key needs to be specified"
puts Lightning.possible_completions(ENV["COMP_LINE"], key)
exit 0
