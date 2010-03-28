module Lightning
  # Runs bin/* commands, handling setup and execution.
  module Commands
    @meta = {}
    extend self

    # Used by bin/* to run commands
    def run_command(command, args)
      @command = command.to_s
      if %w{-h --help}.include?(args[0])
        print_command_help
      else
        send(command, args)
      end
    rescue StandardError, SyntaxError
      $stderr.puts "Error: "+ $!.message
    end

    # Executes a command with given arguments
    def run(argv=ARGV)
      if (command = argv.shift) && (actual_command = unalias_command(command))
        run_command(actual_command, argv)
      elsif command && respond_to?(command)
        run_command(command, argv)
      elsif %w{-v --version}.include?(command)
        puts "lightning #{VERSION}"
      else
        load_user_commands
        puts "Command '#{command}' not found.","\n" if command && !%w{-h --help}.include?(command)
        print_help
      end
    end

    # Array of valid commands
    def commands
      @meta.keys
    end

    private
    def unalias_command(command)
      actual_command = commands.sort.find {|e| e[/^#{command}/] }
      # don't load plugin commands for faster completion/translation
      load_user_commands unless %w{translate complete}.include?(actual_command)
      actual_command || commands.sort.find {|e| e[/^#{command}/] }
    end

    def load_user_commands
      @load_user_commands ||= Util.load_plugins(Lightning.dir, 'commands') || true
    end

    def subcommand_required_args
      meta_array[0].split('|').inject({}) {|a,e|
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
      @meta.sort.each do |command, (usage, desc)|
        puts "  #{command}" << ' ' * (offset - command.size) << desc
      end
    end

    def command_usage
      "Usage: lightning #{@command} #{meta_array[0]}"
    end

    def meta_array
      Array(@meta[@command])
    end

    def print_command_help
      puts [command_usage, '', meta_array[1]]
    end

    def meta(*args)
      @next_meta = args
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

    def method_added(meth)
      @meta[meth.to_s] = @next_meta if @next_meta
      @next_meta = nil
    end
  end
end

Lightning::Util.load_plugins File.dirname(__FILE__), 'commands'