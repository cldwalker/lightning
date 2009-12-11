class Lightning
  class Command
    attr_accessor :name, :paths, :aliases, :post_path, :add_to_command, :desc, :shell_command
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
      @completion_map ||= CompletionMap.new(paths, :global_aliases=>Lightning.config[:aliases],
        :aliases=>aliases)
    end

    def translate_completion(args)
      translated = Array(args).map {|e|
        new_val = completion_map[e] || e
        new_val += @post_path if @post_path && new_val != e
        new_val
      }.join(' ')
      @add_to_command ? translated + @add_to_command : translated
    end
  end
end