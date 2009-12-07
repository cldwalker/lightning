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
    
    def completions
      completion_map.keys
    end

    def completion_map
      @completion_map ||= CompletionMap.new(self.paths,
        :global_aliases=>Lightning.config[:aliases],
        :aliases=>(cmd = Lightning.commands[Lightning.current_command]) && cmd['aliases'])
    end
    
    def resolve_completion(basename)
      basename = basename.join(" ") if basename.is_a?(Array)
      basename.gsub!(/\s*#{TEST_FLAG}\s*/,'')
      #TODO
      # if (regex = Lightning.commands[Lightning.current_command]['completion_regex'])
      #   basename = basename[/#{regex}/]
      # end
      completion_map[basename] || ''
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