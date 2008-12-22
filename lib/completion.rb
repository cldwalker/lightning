# originally from http://github.com/ryanb/dotfiles/tree/master/bash/completion_scripts/project_completion
# Base class for completions
class Completion
  def initialize(command)
    @command = command
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
    raise "abstract method needs to be overidden"
  end
end
