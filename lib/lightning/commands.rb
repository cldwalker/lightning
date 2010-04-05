module Lightning
  # Runs lightning commands.
  module Commands
    @meta = {}
    extend self
    extend CommandsUtil

    # Called by `lightning` to call proper lightning command, print help or print version
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

    # @return [Array] Available lightning commands
    def commands
      @meta.keys
    end

    # Calls proper lightning command with remaining commandline arguments
    def run_command(command, args)
      @command = command.to_s
      if %w{-h --help}.include?(args[0])
        print_command_help
      else
        send(command, args)
      end
    rescue StandardError
      $stderr.puts "Error: "+ $!.message
    end

    # @return [String] Command usage for current command
    def command_usage
      "Usage: lightning #{@command} #{meta_array[0]}"
    end

    # Placed before a command method to set its usage and description
    def meta(*args)
      @next_meta = args
    end

    private
    def print_command_help
      puts [command_usage, '', meta_array[1]]
    end

    def print_help
      puts "lightning COMMAND [arguments]", ""
      puts "Available commands:"
      print_sorted_hash @meta.inject({}) {|a,(k,v)| a[k] = v[1]; a }, true
      puts "", "For more information on a command use:"
      puts "  lightning COMMAND -h", ""
      puts "Options: "
      puts "  -h, --help     Show this help and exit"
      puts "  -v, --version  Print current version and exit"
      puts "", "Commands and subcommands can be abbreviated."
      puts "For example, 'lightning b c gem path1' is short for 'lightning bolt create gem path1'."
    end

    def meta_array
      Array(@meta[@command])
    end

    def unalias_command(command)
      actual_command = commands.sort.find {|e| e[/^#{command}/] }
      # don't load plugin commands for faster completion/translation
      load_user_commands unless %w{translate complete}.include?(actual_command)
      actual_command || commands.sort.find {|e| e[/^#{command}/] }
    end

    def load_user_commands
      @load_user_commands ||= Util.load_plugins(Lightning.dir, 'commands') || true
    end

    def method_added(meth)
      @meta[meth.to_s] = @next_meta if @next_meta
      @next_meta = nil
    end
  end
end

Lightning::Util.load_plugins File.dirname(__FILE__), 'commands'