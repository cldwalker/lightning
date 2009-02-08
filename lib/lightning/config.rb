class Lightning  
  class Config < ::Hash
    class <<self
      attr_accessor :config_file
      def config_file
        @config_file ||= (File.exists?('lightning.yml') ? 'lightning.yml' : File.expand_path(File.join("~",".lightning.yml")))
      end

      def create(options={})
        hash = read_config_file
        obj = new(hash)
        configure_commands_and_paths(obj) if options[:read_only]
        obj
      end
    
      def read_config_file(file=nil)
        default_config = {'shell'=>'bash', 'generated_file'=>File.expand_path(File.join('~', '.lightning_completions')), 
          'complete_regex'=>true}
        @config_file = file if file
        hash = YAML::load_file(config_file)
        default_config.merge(hash)
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
    end
    
    def save
      File.open(self.class.config_file, "w") { |f| f.puts self.to_hash.to_yaml }
    end

    def initialize(hash)
      super
      replace(hash)
      self.replace(self.symbolize_keys)
    end
    
    def to_hash
      hash = Hash.new
      hash.replace(self)
    end
    
    #from Rails' ActiveSupport
    def symbolize_keys
      inject({}) do |options, (key, value)|
        options[(key.to_sym rescue key) || key] = value
        options
      end
    end
    
  end
end

module Lightning::ConfigI  
  def config_command(name, hardcheck=false)
    command = config[:commands].find {|e| e['name'] == name} || {}
    if hardcheck && command.empty?
      puts "Command '#{name}' not found"
      nil
    else
      command
    end
  end
  
  def config_command_paths(name)
    if command = config_command(name, true)
      if command['paths'].is_a?(String)
         Lightning.config[:paths][command['paths']]
      else
        command['paths']
      end
    else
      []
    end
  end
  
  def add_command_alias(command_name, path_alias, path)
    if (command = config_command(command_name, true))
      path = File.expand_path(path)
      command['aliases'][path_alias] = path
      config.save
      puts "Path alias '#{path_alias}' added"
    end
  end
  
  def delete_command_alias(command_name, path_alias)
    if (command = config_command(command_name, true))
      command['aliases'].delete(path_alias)
      config.save
      puts "Path alias '#{path_alias}' deleted"
    end
  end
  
  def add_path(command_name, path)
    if (command = config_command(command_name, true))
      path = File.expand_path(path)
      config_command_paths(command_name) << path
      config.save
      puts "Path '#{path}' added"
    end
  end
  
  def delete_path(command_name, path)
    if (command = config_command(command_name, true))
      path = File.expand_path(path)
      config_command_paths(command_name).delete(path)
      config.save
      puts "Path '#{path}' deleted"
    end
  end
    
  def ignore_paths
    unless @ignore_paths
      @ignore_paths = []
      @ignore_paths += config[:ignore_paths] if config[:ignore_paths] && !config[:ignore_paths].empty?
    end
    @ignore_paths
  end
end
