require 'yaml'
require 'lightning/completion'
require 'lightning/entry_hash'
require 'lightning/core_extensions'
require 'lightning/generator'

class Lightning
  TEST_FLAG = '-test'
  class<<self
    def config
      unless @config
        default_config = {:shell=>'bash', :generated_file=>'generated_lightning'}
        config_yaml_file = File.join(File.dirname(__FILE__), "../lightning.yml")
        @config = YAML::load(File.new(config_yaml_file))
        @config = default_config.merge(@config.symbolize_keys)
        add_command_paths(@config)
      end
      @config
    end
    
    def find_command(name)
      config[:commands].find {|e| e['name'] == name} || {}
    end
    
    def command_to_path_key(map_to_command, new_command)
      "#{map_to_command}-#{new_command}"
    end
    
    def path_key_to_command(path_key)
      path_key.split("-")[1]
    end
    
    def add_command_paths(config)
      config[:paths] ||= {}
      config[:commands].each do |e|
        #mapping a referenced path
        if e['paths'].is_a?(String)
          e['path_key'] = e['paths'].dup
          e['paths'] = config[:paths][e['paths'].strip] || []
        end
        #create a path entry + key if none exists
        if e['path_key'].nil?
          #extract command in case it has options after it
          e['map_to'] =~ /\s*(\w+)/
          path_key = command_to_path_key($1, e['name'])
          # path_key = "#{$1}-#{e['name']}"
          e['path_key'] = path_key
          config[:paths][path_key] = e['paths']
        end
      end
    end
    
    #should return array of globbable paths
    def config_entry(key)
      config[:paths][key]
    end
    
    def exceptions
      unless @exceptions
        @exceptions = ['.', '..']
        @exceptions += config[:ignore] if !config[:ignore].empty?
      end
      @exceptions
    end
    
    def completions_for_key(key)
      entries[key].keys
    end
    
    def generate_source_file(*commands)
      # command_keys = config[:commands].keys if commands.empty?
      # command_hash = config[:commands].slice(*command_keys)
      command_hash = config[:commands]
      output = Generator.generate(config[:shell], command_hash)
      File.open(config[:generated_file], 'w'){|f| f.write(output) }
      output
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
      if (regex = find_command(path_key_to_command(path_key))['completion_regex'])
        basename = basename[/#{regex}/]
      end
      entries[path_key][basename]
    end
  end
end
