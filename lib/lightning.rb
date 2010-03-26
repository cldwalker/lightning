require 'lightning/bolt'
require 'lightning/util'
require 'lightning/commands'
require 'lightning/cli_commands'
require 'lightning/completion'
require 'lightning/config'
require 'lightning/function'
require 'lightning/completion_map'
require 'lightning/builder'
require 'lightning/generators'
require 'lightning/generator'
require 'lightning/version'

module Lightning
  class<<self
    attr_accessor :config

    # @return [Config]
    def config
      @config ||= Config.new
    end

    # Maps bolt names to Bolt objects
    # @return [Hash]
    def bolts
      @bolts ||= Hash.new {|h,k| h[k] = Bolt.new(k) }
    end

    # Maps command names to Function objects
    # @return [Hash]
    def functions
      @functions ||= {}
    end

    # Sets up lightning by generating bolts and functions from config
    def setup
      config.bolts.each {|k,v|
        create_functions bolts[k].generate_functions
      }
    end

    protected
    def create_functions(hash_array)
      hash_array.each {|e| functions[e['name']] = Function.new(e) }
    end
  end
end
