# A bolt is a group of globbable paths referenced by a name.
class Lightning
  class Bolt
    attr_reader :name, :aliases, :desc
    attr_accessor :paths, :commands
    def initialize(name)
      @name = name
      @paths = []
      @commands = []
      @aliases = {}
      (Lightning.config[:bolts][@name] || {}).each do |k,v|
        instance_variable_set("@#{k}", v)
      end
    end
    
    def alias_or_name
      @alias || @name
    end

    def create_command_name(shell_command)
      cmd = only_command shell_command
      "#{Lightning.config.shell_commands[cmd] || cmd}-#{alias_or_name}"
    end

    def only_command(shell_command)
      shell_command[/\w+/]
    end

    def generate_commands
      unique_commands = (@commands + Lightning.config.shell_commands.keys).inject({}) {|acc, e|
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
  end
end