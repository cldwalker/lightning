# derived from http://github.com/ryanb/dotfiles/tree/master/bash/completion_scripts/project_completion
#This class handles completions given a path key and the text already typed.
class Lightning
  class Completion
    def self.complete(text_to_complete, bolt_key)
      new(text_to_complete, bolt_key).matches
    end
      
    def initialize(text_typed, bolt_key)
      @text_typed = text_typed
      @bolt_key = bolt_key
    end
  
    def matches
      possible_completions.select do |e|
        e[0, typed.length] == typed
      end
    end
  
    def typed
      # @text_typed[/\s(.+?)$/, 1] || ''
      text = @text_typed[/^(\S+)\s+(#{Lightning::TEST_FLAG})?\s*(.+?)$/, 3] || ''
      text.strip
    end
  
    def possible_completions
      Lightning.bolts[@bolt_key].completions
    end    
  end
end
