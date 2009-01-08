# derived from http://github.com/ryanb/dotfiles/tree/master/bash/completion_scripts/project_completion
class Lightning
  class Completion
    def initialize(command, key)
      @command = command
      @key = key
    end
  
    def matches
      possible_completions.select do |e|
        e[0, typed.length] == typed
      end
    end
  
    def typed
      @command[/\s(.+?)$/, 1] || ''
    end
  
    def possible_completions
      Lightning.completions_for_key(@key)
    end    
  end
end