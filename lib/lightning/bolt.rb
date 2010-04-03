module Lightning
  # A bolt is a group of file globs (Dir.glob) used by a Function object
  # to generate a CompletionMap.
  class Bolt
    attr_reader :name, :aliases, :global
    attr_accessor :globs, :functions
    def initialize(name)
      @name = name
      @globs = []
      @functions = []
      @aliases = {}
      (Lightning.config.bolts[@name] || {}).each do |k,v|
        instance_variable_set("@#{k}", v)
      end
      @functions += Lightning.config.global_commands if @global
    end

    # Generates functions from a bolt's commands and global shell commands
    def generate_functions
      unique_functions = functions.inject({}) {|acc, e|
        cmd = e.is_a?(Hash) ? e.dup : {'shell_command'=>e}
        acc[Lightning.config.only_command(cmd['shell_command'])] ||= cmd if cmd['shell_command']
        acc
      }.values
      unique_functions.map! do |cmd|
        cmd['bolt'] = self
        cmd['name'] ||= Lightning.config.function_name(cmd['shell_command'], alias_or_name)
        cmd
      end
    end

    def alias_or_name
      @alias || @name
    end
  end
end
