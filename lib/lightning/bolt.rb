# A bolt, referenced by a key, is the basic unit needed to access a lightning command's functionality.
class Lightning
  class Bolt
    attr_reader :key
    attr_accessor :paths
    def initialize(bolt_key)
      @key = bolt_key
      @paths = []
      (Lightning.config[:bolts][@key] || {}).each do |k,v|
        instance_variable_set("@#{k}", v)
      end
    end
    
    def completions
      completion_map.keys
    end
    
    def completion_map
      @completion_map ||= Lightning::CompletionMap.new(self.paths,
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
end
