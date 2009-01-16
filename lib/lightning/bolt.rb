# A bolt, referenced by a key, is the basic unit needed to access a lightning command's functionality.
class Lightning
  class Bolt
    attr_reader :key
    def initialize(bolt_key)
      @key = bolt_key
    end
    
    def completions
      path_map.keys
    end
    
    def path_map
      @path_map ||= Lightning::PathMap.new(self.globbable_paths)
    end
    
    def resolve_completion(basename)
      basename = basename.join(" ") if basename.is_a?(Array)
      basename.gsub!(/\s*#{TEST_FLAG}\s*/,'')
      if (regex = Lightning.config_command(self.path_command)['completion_regex'])
        basename = basename[/#{regex}/]
      end
      path_map[basename] || ''
    end
    
    def globbable_paths
      Lightning.config[:paths][key] || []
    end
    
    def path_command
      key.split("-")[1]
    end
    
  end
end