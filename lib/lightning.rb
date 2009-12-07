$:.unshift(File.dirname(__FILE__)) unless $:.include?(File.dirname(__FILE__))
require 'lightning/bolt'
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

    def read_config
      Lightning.config[:bolts].each {|k,v|
        create_commands bolts[k].generate_commands
      }
    end

    def complete(command, text_to_complete)
      read_config
      (cmd = commands[command]) ? Completion.complete(text_to_complete, command) :
        ["#Error: No paths found for this command.", "If this is a bug contact me."]
    end

    def translate(command, argv)
      read_config
      (cmd = commands[command]) ? cmd.resolve_completion(argv) :
        '#Error-no_paths_found_for_this_command'
    end

    def bolts
      @bolts ||= Hash.new {|h,k| h[k] = Bolt.new(k) }
    end

    def commands
      @commands ||= {}
    end

    def create_commands(hash_array)
      hash_array.each {|e| commands[e['name']] = Command.new(e) }
    end
  end
end
