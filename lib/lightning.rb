require 'lightning/bolt'
require 'lightning/util'
require 'lightning/commands_util'
require 'lightning/commands'
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

    # @return [Config] Contains all user configuration
    def config
      @config ||= Config.new
    end

    # @return [Hash] Maps bolt names to Bolt objects
    def bolts
      @bolts ||= Hash.new {|h,k| h[k] = Bolt.new(k) }
    end

    # @return [Hash] Maps function names to Function objects
    def functions
      @functions ||= {}
    end

    # Sets up lightning by generating bolts and functions from config
    def setup
      config.bolts.each {|k,v|
        create_functions bolts[k].generate_functions
      }
    end

    # @return [String] Directory for most of lightning's files, ~/.lightning
    def dir
      @dir ||= begin
        require 'fileutils'
        FileUtils.mkdir_p File.join(home, '.lightning')
        File.join(home, '.lightning')
      end
    end

    # @return [String] User's home directory, ~
    def home
      @home ||= Util.find_home
    end

    protected
    def create_functions(hash_array)
      hash_array.each {|e| functions[e['name']] = Function.new(e) }
    end
  end
end
