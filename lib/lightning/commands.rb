module Lightning
  # Runs lightning commands which are methods in this namespace.
  #
  # == Command Basics
  # To get a list of commands and their description: +lightning -h+. To get usage and description on
  # a command +lightning COMMAND -h+ i.e +lightning bolt -h+. Any command and subcommand can be abbreviated.
  # For example, +lightning b c gem path1+ is short for +lightning bolt create gem path1+.
  #
  # == Command plugins
  # Lightning looks for command plugins or ruby files in ~/.lightning/commands/. Each plugin can have multiple
  # commands since a command is just a method in Lightning::Commands.
  #
  # A sample command plugin looks like this:
  #   module Lightning::Commands
  #     desc 'COMMAND', 'Prints hello'
  #     def hello(argv)
  #       puts 'hello'
  #     end
  #   end
  #
  # Note that a command's usage and description are set with {Commands#desc desc}. +desc+ is required. A command
  # receives commandline arguments as an array. See {CommandsUtil} for helper methods to be used inside a command.
  #
  # For command plugin examples
  # {read the source}[http://github.com/cldwalker/lightning/tree/master/lib/lightning/commands/].
  module Commands
    @desc = {}
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
      @desc.keys
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
      "Usage: lightning #{@command} #{desc_array[0]}"
    end

    # Place before a command method to set its usage and description
    def desc(*args)
      @next_desc = args
    end

    private
    def print_command_help
      puts [command_usage, '', desc_array[1]]
    end

    def print_help
      puts "lightning COMMAND [arguments]", ""
      puts "Available commands:"
      print_sorted_hash @desc.inject({}) {|a,(k,v)| a[k] = v[1]; a }, true
      puts "", "For more information on a command use:"
      puts "  lightning COMMAND -h", ""
      puts "Options: "
      puts "  -h, --help     Show this help and exit"
      puts "  -v, --version  Print current version and exit"
      puts "", "Commands and subcommands can be abbreviated."
      puts "For example, 'lightning b c gem path1' is short for 'lightning bolt create gem path1'."
    end

    def desc_array
      Array(@desc[@command])
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
      @desc[meth.to_s] = @next_desc if @next_desc
      @next_desc = nil
    end
  end
end

Lightning::Util.load_plugins File.dirname(__FILE__), 'commands'