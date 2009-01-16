module Lightning::Config
  def load_config
    @config = setup_config
  end
  
  def config
    @config ||= setup_config
  end
  
  def setup_config
    hash = read_config_file
    configure_commands_and_paths(hash)
    hash
  end
  
  def read_config_file(config_file=nil)
    default_config = {:shell=>'bash', :generated_file=>File.expand_path(File.join('~', '.lightning_completions'))}
    config_file ||= File.exists?('lightning.yml') ? 'lightning.yml' : File.expand_path(File.join("~",".lightning.yml"))
    hash = YAML::load(File.new(config_file))
    default_config.merge(hash.symbolize_keys)
  end
  
  def config_command(name)
    config[:commands].find {|e| e['name'] == name} || {}
  end
  
  def commands_to_bolt_key(map_to_command, new_command)
    "#{map_to_command}-#{new_command}"
  end
  
  def configure_commands_and_paths(hash)
    hash[:paths] ||= {}
    hash[:commands].each do |e|
      #mapping a referenced path
      if e['paths'].is_a?(String)
        e['bolt_key'] = e['paths'].dup
      end
      #create a path entry + key if none exists
      if e['bolt_key'].nil?
        #extract command in case it has options after it
        e['map_to'] =~ /\s*(\w+)/
        bolt_key = commands_to_bolt_key($1, e['name'])
        e['bolt_key'] = bolt_key
        hash[:paths][bolt_key] = e['paths'] || []
      end
    end
    hash
  end
  
  def ignore_paths
    unless @ignore_paths
      @ignore_paths = []
      @ignore_paths += config[:ignore_paths] if config[:ignore_paths] && !config[:ignore_paths].empty?
    end
    @ignore_paths
  end
end
