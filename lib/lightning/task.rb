class Task < Thor
  map 'p'=>:path, 'c'=>:command, 'lc'=>:lightning_command, 'a'=>:alias
  desc "lightning_command", "lightning_command"
  method_options :search=>:optional, :command=>:optional
  def lightning_command(*args)
    puts "Lightning Commands"
    if options[:command]
      lightning_commands = Lightning.config[:commands].select {|e| e['map_to'] == options['command']}
    else
      lightning_commands = Lightning.config[:commands]
    end
    puts lightning_commands.map {|e| e['name'] }.join("\n")
  end

  desc "path", "path"
  method_options :add=>:boolean, :delete=>:boolean
  def path(*args)
    command_name = args.shift
    if options['delete']
      return puts("Path needed") if args[0].nil?
      Lightning.delete_path(command_name, args[0])
    elsif options['add']
      return puts("Path needed") if args[0].nil?
      Lightning.add_path(command_name, args[0])
    else
      puts "Paths for command '#{command_name}'"
      puts Lightning.config_command_paths(command_name).join("\n")
    end
  end
    
  desc "alias", "alias"
  method_options :delete=>:boolean, :add=>:boolean, :global=>:boolean
  def alias(*args)
    if options['delete']
      Lightning.delete_command_alias(*args.slice(0,2))
    elsif options['add']
      Lightning.add_command_alias(*args.slice(0,3))
    else
      puts "Aliases"
      (Lightning.config[:aliases] || []).each do |path_alias, path|
        puts "#{path_alias} : #{path}"
      end
    end
  end  
end
