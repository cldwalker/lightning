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
      @functions ||= create_functions
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
    def create_functions
      config.bolts.inject({}) {|h,(k,v)|
        bolts[k].generate_functions.each {|f| h[f['name']] = Function.new(f) } ; h
      }
    end
  end
end
