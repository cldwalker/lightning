require 'yaml'
require 'lightning/completion'
require 'lightning/entry_hash'

class Lightning
  VERSION = '0.1.0'
  class<<self
    #should return array of globbable paths
    def config_entry(key)
      config_yaml_file = File.join(File.dirname(__FILE__), "../lightning.yml")
      YAML::load(File.new(config_yaml_file))[key]
    end
    
    def exceptions
      ['.', '..']
    end
    
    def completions_for_key(key)
      entries[key].keys
    end
    
    def entries
      @entry_hash ||= EntryHash.new
    end
    
    def possible_completions(text, key)
      Completion.new(ENV["COMP_LINE"], key).matches
    end
    
    def full_path_for_completion(basename, key)
      entries[key][basename]
    end
  end
end