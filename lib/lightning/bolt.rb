# A bolt is a group of globbable paths referenced by a name. A bolt can resolve completions
# for its paths by using a CompletionMap.
class Lightning
  class Bolt
    attr_reader :name
    attr_accessor :paths, :shell_commands
    def initialize(name)
      @name = name
      @paths = []
      @shell_commands = []
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
  end

  def create_command_name(shell_command)
    "#{shell_command[/^\w+/]}-#{name}"
  end

  def create_commands
    shell_commands.each do |hash|
      hash = {'map_to'=>hash, 'bolt'=>name, 'paths'=>paths, 'name'=>create_command_name(hash, name)} unless hash.is_a?(Hash)
      Command.new(hash)
    end
  end
end