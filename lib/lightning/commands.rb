module Lightning
  # Runs bin/* commands, handling setup and execution.
  module Commands
    @usage = {}
    extend self

    # Used by bin/* to run commands
    def run_command(command, args)
      @command = command.to_s
      if %w{-h --help}.include?(args[0])
        print_command_help
      else
        send("#{command}_command", args)
      end
    rescue StandardError, SyntaxError
      $stderr.puts "Error: "+ $!.message
    end

    # Executes a command with given arguments
    def run(argv=ARGV)
      if (command = argv.shift) && (actual_command = commands.sort.find {|e| e[/^#{command}/] })
        run_command(actual_command, argv)
      elsif respond_to?("#{command}_command")
        run_command(command, argv)
      elsif %w{-v --version}.include?(command)
        puts "lightning #{VERSION}"
      else
        puts "Command '#{command}' not found.","\n" if command && !%w{-h --help}.include?(command)
        print_help
      end
    end

    # Array of valid commands
    def commands
      @usage.keys
    end

    def load_plugin(file)
        require file
    rescue Exception => e
      puts "Error: Command plugin '#{file}' failed to load:", e.message
    end

    private
    def subcommand_required_args
      Array(@usage[@command])[0].split('|').inject({}) {|a,e|
        cmd, *args = e.strip.split(/\s+/)
        a[cmd] = args.select {|e| e[/^[A-Z]/]}.size
        a
      }
    end

    def subcommand_has_required_args(subcommand, argv)
      return true if argv.size >= (subcommand_required_args[subcommand] || 0)
      puts "'lightning #{@command} #{subcommand}' was called incorrectly.", command_usage
    end

    def command_has_required_args(argv, required)
      return true if argv.size >= required
      puts "'lightning #{@command}' was called incorrectly.", command_usage
    end

    def print_help
      puts "lightning COMMAND [arguments]", ""
      puts "Available commands:"
      print_command_table
      puts "", "For more information on a command use:"
      puts "  lightning COMMAND -h", ""
      puts "Options: "
      puts "  -h, --help     Show this help and exit"
      puts "  -v, --version  Print current version and exit"
      puts "", "Commands and subcommands can be abbreviated."
      puts "For example, 'lightning b a gem path1' is short for 'lightning bolt add gem path1'."
    end

    def print_command_table
      offset = commands.map {|e| e.size }.max + 2
      offset += 1 unless offset % 2 == 0
      @usage.sort.each do |command, (usage, desc)|
        puts "  #{command}" << ' ' * (offset - command.size) << desc
      end
    end

    def command_usage
      "Usage: lightning #{@command} #{usage_array[0]}"
    end

    def usage_array
      Array(@usage[@command])
    end

    def print_command_help
      puts [command_usage, '', usage_array[1]]
    end

    def usage(command, *args)
      @usage[command] = args
    end

    def parse_args(args)
      options, args = args.partition {|e| e =~ /^-/ }
      options = options.inject({}) do |hash, flag|
        key, value = flag.split('=')
        value = true if value.nil?
        hash[key.sub(/^--?/,'').intern] = value.to_s[/,/] ? value.split(',') : value
        hash
      end
      [args, options]
    end

    def list_subcommand(list_type, argv)
      if %w{-a --alias}.include?(argv[0])
        puts Lightning.config.send(list_type).keys.sort.map {|e|
          list_type == :shell_commands ?
            "#{e}: #{Lightning.config.send(list_type)[e]}" :
            "#{e}: #{Lightning.config.send(list_type)[e]['alias']}"
        }
      else
        puts Lightning.config.send(list_type).keys.sort
      end
    end
  end
end

if File.exists?(dir = File.join(File.dirname(__FILE__), 'commands'))
  Dir[dir + '/*.rb'].each do |file|
    Lightning::Commands.load_plugin(file)
  end
end