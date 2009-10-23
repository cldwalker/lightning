class Lightning
  # TODO: Provide commands for the lightning binary.
  module Commands
    # @options :search=>:string, :command=>:string
    def lightning_command(*args)
      puts "Lightning Commands"
      if options[:command]
        lightning_commands = Lightning.config[:commands].select {|e| e['map_to'] == options['command']}
      else
        lightning_commands = Lightning.config[:commands]
      end
      puts lightning_commands.map {|e| e['name'] }.join("\n")
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
        puts config_command_paths(command_name).join("\n")
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
    def config_command_paths(name)
      if command = Lightning.config_command(name, true)
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
      if (command = Lightning.config_command(command_name, true))
        path = File.expand_path(path)
        command['aliases'][path_alias] = path
        Lightning.config.save
        puts "Path alias '#{path_alias}' added"
      end
    end

    def delete_command_alias(command_name, path_alias)
      if (command = Lightning.config_command(command_name, true))
        command['aliases'].delete(path_alias)
        Lightning.config.save
        puts "Path alias '#{path_alias}' deleted"
      end
    end

    def add_path(command_name, path)
      if (command = Lightning.config_command(command_name, true))
        path = File.expand_path(path)
        config_command_paths(command_name) << path
        Lightning.config.save
        puts "Path '#{path}' added"
      end
    end

    def delete_path(command_name, path)
      if (command = Lightning.config_command(command_name, true))
        path = File.expand_path(path)
        config_command_paths(command_name).delete(path)
        Lightning.config.save
        puts "Path '#{path}' deleted"
      end
    end
  end
end
