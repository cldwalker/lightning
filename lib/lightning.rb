$:.unshift(File.dirname(__FILE__)) unless $:.include? File.expand_path(File.dirname(__FILE__))
require 'lightning/bolt'
require 'lightning/util'
require 'lightning/cli'
require 'lightning/cli_commands'
require 'lightning/completion'
require 'lightning/config'
require 'lightning/command'
require 'lightning/completion_map'
require 'lightning/builder'
require 'lightning/generators'
require 'lightning/generator'

class Lightning
  class<<self
    attr_accessor :config
    def config
      @config ||= Config.new
    end

    def bolts
      @bolts ||= Hash.new {|h,k| h[k] = Bolt.new(k) }
    end

    def commands
      @commands ||= {}
    end
  end
end