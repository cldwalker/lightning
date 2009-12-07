module Commands
  def self.included(mod)
    require 'local_gem'
    LocalGem.local_require 'lightning'
    Lightning.read_config
  end

  # @render_options :fields=>[:name, :alias_or_name, :paths], :filters=>{:default=>{:paths=>:inspect}}
  # @config :alias=>'b'
  def bolts
    Lightning.bolts.values
  end

  # @render_options :fields=>{:default=>%w{name shell_command bolt paths}, :values=>%w{name shell_command bolt paths aliases}},
  #  :filters=>{:default=>{'paths'=>:inspect, 'aliases'=>:inspect}}
  # @config :alias=>'bcom'
  def bolt_commands
    Lightning.commands.values
  end

  #@options :add=>:boolean, :delete=>:boolean
  def path(*args)
    command_name = args.shift
    if options['delete']
      return puts("Path needed") if args[0].nil?
      delete_path(command_name, args[0])
    elsif options['add']
      return puts("Path needed") if args[0].nil?
      add_path(command_name, args[0])
    else
      puts "Paths for command '#{command_name}'"
      puts command_paths(command_name).join("\n")
    end
  end

  #@options :delete=>:boolean, :add=>:boolean, :global=>:boolean
  def alias(*args)
    if options['delete']
      delete_command_alias(*args.slice(0,2))
    elsif options['add']
      add_command_alias(*args.slice(0,3))
    else
      puts "Aliases"
      (Lightning.config[:aliases] || []).each do |path_alias, path|
        puts "#{path_alias} : #{path}"
      end
    end
  end

  private
  def command_paths(name)
    if (command = Lightning.commands[command_name])
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
    if (command = Lightning.commands[command_name])
      path = File.expand_path(path)
      command['aliases'][path_alias] = path
      Lightning.config.save
      puts "Path alias '#{path_alias}' added"
    end
  end

  def delete_command_alias(command_name, path_alias)
    if (command = Lightning.commands[command_name])
      command['aliases'].delete(path_alias)
      Lightning.config.save
      puts "Path alias '#{path_alias}' deleted"
    end
  end

  def add_path(command_name, path)
    if (command = Lightning.commands[command_name])
      path = File.expand_path(path)
      command_paths(command_name) << path
      Lightning.config.save
      puts "Path '#{path}' added"
    end
  end

  def delete_path(command_name, path)
    if (command = Lightning.commands[command_name])
      path = File.expand_path(path)
      command_paths(command_name).delete(path)
      Lightning.config.save
      puts "Path '#{path}' deleted"
    end
  end
end
