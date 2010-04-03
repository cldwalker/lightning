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
      @functions += Lightning.config.shell_commands.keys if @global
    end

    # Creates a command name from its shell command and bolt i.e. "#{command}-#{bolt}".
    # Uses aliases for either if they exist.
    def create_function_name(shell_command)
      cmd = only_command shell_command
      "#{Lightning.config.shell_commands[cmd] || cmd}-#{alias_or_name}"
    end

    # Extracts shell command from a shell_command string
    def only_command(shell_command)
      shell_command[/\w+/]
    end

    # Generates functions from a bolt's commands and global shell commands
    def generate_functions
      unique_functions = functions.inject({}) {|acc, e|
        cmd = e.is_a?(Hash) ? e.dup : {'shell_command'=>e}
        acc[only_command(cmd['shell_command'])] ||= cmd if cmd['shell_command']
        acc
      }.values
      unique_functions.map! do |cmd|
        cmd['bolt'] = self
        cmd['name'] ||= create_function_name(cmd['shell_command'])
        cmd
      end
    end

    protected
    def alias_or_name
      @alias || @name
    end
  end
end
