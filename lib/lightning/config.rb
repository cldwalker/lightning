module Lightning::Config
  def config
    unless @config
      default_config = {:shell=>'bash', :generated_file=>'lightning_completions'}
      config_yaml_file = File.expand_path File.join("~",".lightning.yml")
      @config = YAML::load(File.new(config_yaml_file))
      @config = default_config.merge(@config.symbolize_keys)
      add_command_paths(@config)
    end
    @config
  end
  
  def config_command(name)
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
  
  def exceptions
    unless @exceptions
      @exceptions = ['.', '..']
      @exceptions += config[:ignore] if !config[:ignore].empty?
    end
    @exceptions
  end
end