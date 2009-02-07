$:.unshift(File.dirname(__FILE__)) unless $:.include?(File.dirname(__FILE__))
require 'yaml'
require 'lightning/bolt'
require 'lightning/bolts'
require 'lightning/completion'
require 'lightning/config'
require 'lightning/completion_map'
require 'lightning/core_extensions'
require 'lightning/generator'

class Lightning
  TEST_FLAG = '-test'
  extend ConfigI
  class<<self
    attr_accessor :current_command
    def config(options={})
      @config ||= Config.create(options)
    end
    
    def load_read_only_config
      @config = Config.create(:read_only=>true)
    end
    
    def config=(value)
      @config = Config.new(value)
    end
    
    def complete(command, text_to_complete)
      load_read_only_config
      @current_command = command
      if bolt_key = config_command(command)['bolt_key']
        Completion.complete(text_to_complete, bolt_key)
      else
        ["Error: No paths found for this command.", "If this is a bug contact me."]
      end
    end
    
    def translate(command, argv)
      load_read_only_config
      @current_command = command
      if bolt_key = config_command(command)['bolt_key']
        bolts[bolt_key].resolve_completion(argv)
      else
        'Error-no_paths_found_for_this_command'
      end
    end
    
    def bolts
      @bolts ||= Bolts.new
    end
  end
end
