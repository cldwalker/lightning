# derived from http://github.com/ryanb/dotfiles/tree/master/bash/completion_scripts/project_completion
#This class handles completions given the text already typed and a command name.
class Lightning
  class Completion
    def self.complete(text_to_complete, command)
      new(text_to_complete, command).matches
    end
      
    def initialize(text_typed, command)
      @text_typed = text_typed
      @command = command
    end
  
    def matches
      if Lightning.config[:complete_regex]
        begin 
          possible_completions.grep(/#{blob_to_regex(typed)}/)
        rescue RegexpError
          ['#Error: Invalid regular expression']
        end
      else
        possible_completions.select do |e|
          e[0, typed.length] == typed
        end
      end
    end
    
    #just converts * to .*  to make a glob-like regex
    def blob_to_regex(string)
      string.gsub(/^\*|([^\.])\*/) {|e| $1 ? $1 + ".*" : ".*" }
    end
  
    def typed
      # @text_typed[/\s(.+?)$/, 1] || ''
      text = @text_typed[/^(\S+)\s+(#{Lightning::TEST_FLAG})?\s*(.+?)$/, 3] || ''
      text.strip
    end
  
    def possible_completions
      Lightning.commands[@command].completions
    end    
  end
end
