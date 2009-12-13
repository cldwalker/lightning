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
      cmd = shell_command[/\w+/]
      "#{Lightning.config.shell_commands[cmd] || cmd}-#{alias_or_name}"
    end

    def generate_commands
      generated = []
      (Lightning.config.shell_commands.keys + @commands).each do |hash|
        hash = {'shell_command'=>hash} unless hash.is_a?(Hash)
        hash['bolt'] = self
        hash['name'] ||= create_command_name(hash['shell_command'])
        generated << hash
      end
      generated
    end
  end
end