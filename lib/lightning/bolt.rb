# A bolt is a group of globbable paths referenced by a name. A bolt can resolve completions
# for its paths by using a CompletionMap.
class Lightning
  class Bolt
    attr_reader :name
    attr_accessor :paths, :commands
    def initialize(name)
      @name = name
      @paths = []
      @commands = []
      (Lightning.config[:bolts][@name] || {}).each do |k,v|
        instance_variable_set("@#{k}", v)
      end
    end
    
    def alias_or_name
      @alias || @name
    end

    def create_command_name(shell_command)
      cmd = shell_command[/\w+/]
      "#{Lightning.config[:shell_commands][cmd] || cmd}-#{alias_or_name}"
    end

    def generate_commands
      commands.map do |hash|
        hash = {'shell_command'=>hash} unless hash.is_a?(Hash)
        hash['name'] ||= create_command_name(hash['shell_command'])
        hash['paths'] ||= paths
        hash['bolt'] ||= name
        hash
      end
    end
  end
end