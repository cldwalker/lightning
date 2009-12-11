class Lightning
  class Command
    ATTRIBUTES = :name, :paths, :aliases, :post_path, :add_to_command, :desc, :shell_command, :bolt
    attr_accessor *ATTRIBUTES
    def initialize(hash)
      raise ArgumentError, "Command must have a name" unless hash['name']
      hash.each do |k,v|
        instance_variable_set("@#{k}", v)
      end
    end

    def completions
      completion_map.keys
    end

    def paths
      @paths ||= []
    end

    def completion_map
      @completion_map ||= CompletionMap.new(paths, :aliases=>aliases)
    end

    def translate_completion(args)
      translated = Array(args).map {|arg|
        new_arg = completion_map[arg] || arg.dup
        new_arg << @post_path if @post_path && new_arg != arg
        if new_arg == arg && (dir = new_arg[/^([^\/]+)\//,1]) && (full_dir = completion_map[dir])
          new_arg.sub!(dir, full_dir)
        end
        new_arg
      }.join(' ')
      @add_to_command ? translated + @add_to_command : translated
    end
  end
end