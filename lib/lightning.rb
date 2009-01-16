$:.unshift(File.dirname(__FILE__)) unless $:.include?(File.dirname(__FILE__))
require 'yaml'
require 'lightning/bolt'
require 'lightning/bolts'
require 'lightning/completion'
require 'lightning/config'
require 'lightning/path_map'
require 'lightning/core_extensions'
require 'lightning/generator'

class Lightning
  TEST_FLAG = '-test'
  extend Config
  class<<self
    def complete(text_to_complete, bolt_key)
      load_config
      Complete.complete(text_to_complete, bolt_key)
    end
    
    def translate(key, argv)
      load_config
      bolts[key].resolve_completion(argv)
    end
    
    def bolts
      @bolts ||= Bolts.new
    end
  end
end
