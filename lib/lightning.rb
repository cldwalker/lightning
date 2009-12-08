$:.unshift(File.dirname(__FILE__)) unless $:.include?(File.dirname(__FILE__))
require 'lightning/bolt'
require 'lightning/cli'
require 'lightning/completion'
require 'lightning/config'
require 'lightning/command'
require 'lightning/completion_map'
require 'lightning/generator'

class Lightning
  TEST_FLAG = '-test'
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