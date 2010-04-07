require 'shellwords'

module Lightning
  # This class returns completions for the last word typed for a given lightning function and its {Function} object.
  # Inspired loosely by ryanb[http://github.com/ryanb/dotfiles/tree/master/bash/completion_scripts/project_completion].
  class Completion
    # @return [Array] Returns completions that match last word typed
    def self.complete(text_to_complete, function, shellescape=true)
      return error_array("No function found to complete.") unless function
      new(text_to_complete, function, shellescape).matches
    end

    # @return [Array] Constructs completion error message. More than one element long to ensure error message
    # gets displayed and not completed
    def self.error_array(message)
      ["#Error: #{message}", "Please open an issue."]
    end

    def initialize(text_typed, function, shellescape=true)
      @text_typed = text_typed
      @function = function
      @shellescape = shellescape
    end
  
    # @return [Array] Main method to determine and return completions that match
    def matches
      matched = get_matches(possible_completions)
      matched = match_when_completing_subdirectories(matched)
      @shellescape ? matched.map {|e| Util.shellescape(e) } : matched
    rescue SystemCallError
      self.class.error_array("Nonexistent directory.")
    rescue RegexpError
      self.class.error_array("Invalid regular expression.")
    end

    # @param [Array]
    # @return [Array] Selects possible completions that match using {Completion#typed typed}
    def get_matches(possible)
      Lightning.config[:complete_regex] ? possible.grep(/^#{blob_to_regex(typed)}/) :
        possible.select {|e| e[0, typed.length] == typed }
    end

    # @param [Array]
    # @return [Array] Generates completions when completing a directory above or below a basename
    def match_when_completing_subdirectories(matched)
      if matched.empty? && (top_dir = typed[/^([^\/]+)\//,1]) && !typed.include?('//')
        matched = possible_completions.grep(/^#{top_dir}/)

        # for typed = some/dir/file, top_dir = path and translated_dir = /full/bolt/path
        if matched.size == 1 && (translated_dir = @function.translate([top_dir])[0])
          short_dir = typed.sub(/\/([^\/]+)?$/, '')  # some/dir
          completed_dir = short_dir.sub(top_dir, translated_dir) #/full/bolt/path/some/dir
          completed_dir = File.expand_path(completed_dir) if completed_dir[/\/\.\.($|\/)/]
          matched = Dir.entries(completed_dir).delete_if {|e| %w{. ..}.include?(e) }.map {|f|
            File.directory?(completed_dir+'/'+f) ? File.join(short_dir,f) +'/' : File.join(short_dir,f)
          }
          matched = get_matches(matched)
        end
      end
      matched
    end

    # @return [String] Last word typed by user
    def typed
      @typed ||= begin
        args = Shellwords.shellwords(@text_typed)
        !args[-1][/\s+/] && @text_typed[/\s+$/] ? '' : args[-1]
      end
    end

    # @private Converts * to .*  to make a glob-like regex when in regex completion mode
    def blob_to_regex(string)
      string.gsub(/^\*|([^\.])\*/) {|e| $1 ? $1 + ".*" : ".*" }
    end

    protected
    def possible_completions
      @function.completions
    end
  end
end
