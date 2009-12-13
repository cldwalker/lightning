require 'shellwords'

# derived from http://github.com/ryanb/dotfiles/tree/master/bash/completion_scripts/project_completion
#This class handles completions given the text already typed and a command name.
class Lightning
  class Completion
    def self.complete(text_to_complete, command, shellescape=true)
      new(text_to_complete, command, shellescape).matches
    end
      
    def initialize(text_typed, command, shellescape=true)
      @text_typed = text_typed
      @command = command
      @shellescape = shellescape
    end
  
    def matches
      matched = get_matches(possible_completions)
      matched = match_when_completing_subdirectories(matched)
      @shellescape ? matched.map {|e| Util.shellescape(e) } : matched
    rescue SystemCallError
      ["#Error: Nonexistent directory"]
    rescue RegexpError
      ['#Error: Invalid regular expression']
    end

    def get_matches(possible)
      if Lightning.config[:complete_regex]
          possible.grep(/^#{blob_to_regex(typed)}/)
      else
        possible.select {|e| e[0, typed.length] == typed }
      end
    end

    def match_when_completing_subdirectories(matched)
      if matched.empty? && (top_dir = typed[/^([^\/]+)\//,1]) && !typed.include?('//')
        matched = possible_completions.grep(/^#{top_dir}/)

        # for typed = some/dir/file, top_dir = path and translated_dir = /full/bolt/path
        if matched.size == 1 && (translated_dir = @command.translate_completion([top_dir]))
          short_dir = typed.sub(/\/([^\/]+)?$/, '')  # some/dir
          completed_dir = short_dir.sub(top_dir, translated_dir) #/full/bolt/path/some/dir
          matched = Dir.entries(completed_dir).delete_if {|e| %w{. ..}.include?(e) }.map {|f|
            File.directory?(completed_dir+'/'+f) ? File.join(short_dir,f) +'/' : File.join(short_dir,f)
          }
          matched = get_matches(matched)
        end
      end
      matched
    end

    #just converts * to .*  to make a glob-like regex
    def blob_to_regex(string)
      string.gsub(/^\*|([^\.])\*/) {|e| $1 ? $1 + ".*" : ".*" }
    end

    def typed
      @typed ||= begin
        args = Shellwords.shellwords(@text_typed)
        !args[-1][/\s+/] && @text_typed[/\s+$/] ? '' : args[-1]
      end
    end

    def possible_completions
      @command.completions
    end
  end
end
