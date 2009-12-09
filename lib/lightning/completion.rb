require 'shellwords'

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
      get_matches.map {|e| Util.shellescape(e) }
    rescue RegexpError
      ['#Error: Invalid regular expression']
    end

    def get_matches
      if Lightning.config[:complete_regex]
          possible_completions.grep(/^#{blob_to_regex(typed)}/)
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
      args = Shellwords.shellwords(@text_typed)
      !args[-1][/\s+/] && @text_typed[/\s+$/] ? '' : args[-1]
    end
  
    def possible_completions
      @command.completions
    end
  end
end
