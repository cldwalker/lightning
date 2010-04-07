module Lightning
  # A Function object represents a shell function which wraps around a shell command and a {Bolt}.
  # This shell function autocompletes bolt paths by their basenames and translates arguments that
  # are these basenames to their full paths.
  class Function
    ATTRIBUTES = :name, :post_path, :shell_command, :bolt, :desc
    attr_accessor *ATTRIBUTES
    def initialize(hash)
      raise ArgumentError, "Function must have a name and bolt" unless hash['name'] && hash['bolt']
      hash.each do |k,v|
        instance_variable_set("@#{k}", v)
      end
    end

    # @return [Array] All possible completions
    def completions
      completion_map.keys
    end

    # @return [Array] Globs used to create {Function#completion_map completion_map}
    def globs
      @globs ||= @bolt.globs
    end

    # User-defined aliases for any path. Defaults to its bolt's aliases.
    # @return [Hash] Maps aliases to full paths
    def aliases
      @aliases ||= @bolt.aliases
    end

    # @return [CompletionMap] Map of basenames to full paths used in completion
    def completion_map
      @completion_map ||= CompletionMap.new(globs, :aliases=>aliases)
    end

    # @return [Array] Translates function's arguments
    def translate(args)
      translated = Array(args).map {|arg|
        !completion_map[arg] && (new_arg = arg[/^(.*)\.\.$/,1]) ?
          Completion.complete(new_arg, self, false) : arg
      }.flatten.map {|arg|
        new_arg = completion_map[arg] || arg.dup
        new_arg << @post_path if @post_path && new_arg != arg
        if new_arg == arg && (dir = new_arg[/^([^\/]+)\//,1]) && (full_dir = completion_map[dir])
          new_arg.sub!(dir, full_dir)
          new_arg = File.expand_path(new_arg)
        end
        new_arg
      }
    end
  end
end