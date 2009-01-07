#!/usr/bin/env ruby

# == Description
# Used by path completion functions to return first possible full path which matches the given basename for the given key.
# Warning: Basenames that occur in multiple directories will return the first directory found.

$:.unshift File.join(File.dirname(__FILE__), '../lib')
require 'lightning'

key = ARGV.shift or raise "No key given"
basename = ARGV.shift or raise "No basename given"
puts Lightning.full_path_for_completion(basename, key) || ''
exit 0