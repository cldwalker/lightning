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
    attr_accessor :current_command, :config
    def config
      @config ||= Config.new
    end
    
    def read_config
      config[:commands].each do |e|
        commands[e['name']] = Command.new(e)
      end
    end
    
    def complete(command, text_to_complete)
      read_config
      @current_command = command
      if (cmd = commands[command]) && cmd['bolt']
        Completion.complete(text_to_complete, cmd['bolt'])
      else
        ["#Error: No paths found for this command.", "If this is a bug contact me."]
      end
    end
    
    def translate(command, argv)
      read_config
      @current_command = command
      if (cmd = commands[command]) && cmd['bolt']
        bolts[cmd['bolt']].resolve_completion(argv)
      else
        '#Error-no_paths_found_for_this_command'
      end
    end
    
    def bolts
      @bolts ||= Hash.new {|h,k| h[k] = Bolt.new(k) }
    end

    def commands
      @commands ||= {}
    end
  end
end
