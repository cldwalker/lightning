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

    # Maps command names to Command objects
    # @return [Hash]
    def commands
      @commands ||= {}
    end

    # Sets up lightning by generating bolts and commands from config
    def setup
      config.bolts.each {|k,v|
        create_commands bolts[k].generate_commands
      }
    end

    protected
    def create_commands(hash_array)
      hash_array.each {|e| commands[e['name']] = Command.new(e) }
    end
  end
end