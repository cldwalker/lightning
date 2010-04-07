module Lightning
  # A Function object represents a shell function which wraps around a shell command and a {Bolt}.
  # This shell function autocompletes bolt paths by their basenames and translates arguments that
  # are these basenames to their full paths.
  #
  # == Argument Translation
  # Before executing its shell command, a function checks each argument to see if it can translate it.
  # Translation is done if the argument matches the basename of one its bolt's paths.
  #   $echo-ruby irb.rb
  #   /System/Library/Frameworks/Ruby.framework/Versions/1.8/usr/lib/ruby/1.8/irb.rb.
  #
  # For translation to occur, the full basename must match. The only exception to this is when using
  # lightning's own filename expansion syntax: a '..' at the end of an argument expands the argument
  # with all completions that matched up to '..'. For example:
  #   $echo-ruby ad..
  #   /System/Library/Frameworks/Ruby.framework/Versions/1.8/usr/lib/ruby/1.8/osx/addressbook.rb
  #   /System/Library/Frameworks/Ruby.framework/Versions/1.8/usr/lib/ruby/1.8/wsdl/soap/address.rb
  #
  # This expansion of any bolt paths combined with regex completion makes for a powerfully quick
  # way of typing paths.
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