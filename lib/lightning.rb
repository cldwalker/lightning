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
    def reset_bolts
      @bolts = {}
    end
    
    def bolts
      @bolts ||= Bolts.new
    end
  end
end
