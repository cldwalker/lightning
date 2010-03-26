module Lightning
  # A bolt is a group of globbable paths (Dir.glob) used by a Command object
  # to generate a CompletionMap.
  class Bolt
    attr_reader :name, :aliases, :desc
    attr_accessor :paths, :commands
    def initialize(name)
      @name = name
      @paths = []
      @add_commands = []
      @aliases = {}
      (Lightning.config.bolts[@name] || {}).each do |k,v|
        instance_variable_set("@#{k}", v)
      end
      @commands ||= Lightning.config.shell_commands.keys
      @commands = @add_commands + @commands
    end

    # Creates a command name from its shell command and bolt i.e. "#{command}-#{bolt}".
    # Uses aliases for either if they exist.
    def create_command_name(shell_command)
      cmd = only_command shell_command
      "#{Lightning.config.shell_commands[cmd] || cmd}-#{alias_or_name}"
    end

    # Extracts shell command from a shell_command string
    def only_command(shell_command)
      shell_command[/\w+/]
    end

    # Generates commands from a bolt's commands and global shell commands
    def generate_commands
      unique_commands = commands.inject({}) {|acc, e|
        cmd = e.is_a?(Hash) ? e : {'shell_command'=>e}
        acc[only_command(cmd['shell_command'])] ||= cmd
        acc
      }.values
      unique_commands.map! do |cmd|
        cmd['bolt'] = self
        cmd['name'] ||= create_command_name(cmd['shell_command'])
        cmd
      end
    end

    protected
    def alias_or_name
      @alias || @name
    end
  end
end