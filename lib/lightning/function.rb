module Lightning
  # A Function wraps around a shell command and provides autocompletion and
  # translation of basenames to full path names. It depends on a Bolt object for
  # the globbable paths and a CompletionMap object to map basenames to full paths.
  class Function
    ATTRIBUTES = :name, :post_path, :shell_command, :bolt, :desc
    attr_accessor *ATTRIBUTES
    def initialize(hash)
      raise ArgumentError, "Function must have a name and bolt" unless hash['name'] && hash['bolt']
      hash.each do |k,v|
        instance_variable_set("@#{k}", v)
      end
    end

    # @return [Array]
    def completions
      completion_map.keys
    end

    # @return [Array] Globs used by completion_map
    def globs
      @globs ||= @bolt.globs
    end

    # Custom aliases in case a basename is too long. Defaults to a bolt's aliases.
    # @return [Hash] Maps aliases to full paths
    def aliases
      @aliases ||= @bolt.aliases
    end

    # Used to match a given basename with its full path
    # @return [CompletionMap]
    def completion_map
      @completion_map ||= CompletionMap.new(globs, :aliases=>aliases)
    end

    # Translates each element in an array of completions.
    def translate_completion(args)
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
      }.join("\n")
    end
  end
end