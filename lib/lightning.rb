$:.unshift(File.dirname(__FILE__)) unless $:.include?(File.dirname(__FILE__))
require 'yaml'
require 'lightning/completion'
require 'lightning/config'
require 'lightning/entry_hash'
require 'lightning/core_extensions'
require 'lightning/generator'

class Lightning
  TEST_FLAG = '-test'
  extend Config
  class<<self    
    def completions_for_key(key)
      entries[key].keys
    end
    
    #should return array of globbable paths
    def paths_for_key(key)
      config[:paths][key]
    end

    def entries
      @entry_hash ||= EntryHash.new
    end
    
    def possible_completions(text_to_complete, path_key)
      Completion.new(text_to_complete, path_key).matches
    end
    
    def full_path_for_completion(basename, path_key)
      basename = basename.join(" ") if basename.is_a?(Array)
      basename.gsub!(/\s*#{TEST_FLAG}\s*/,'')
      if (regex = config_command(path_key_to_command(path_key))['completion_regex'])
        basename = basename[/#{regex}/]
      end
      entries[path_key][basename]
    end
  end
end
