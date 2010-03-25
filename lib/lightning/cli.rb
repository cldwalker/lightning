module Lightning
  # Runs bin/* commands, handling setup and execution.
  module Cli
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
        puts VERSION
      else
        puts "Command '#{command}' not found.","\n" if command && !%w{-h --help}.include?(command)
        print_help
      end
    end

    # Array of valid commands
    def commands
      @usage.keys
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
      puts "'lightning #{@command} #{subcommand}' was called incorrectly."
      puts command_usage
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
        hash[key.sub(/^--?/,'').intern] = value.nil? ? true : value
        hash
      end
      [args, options]
    end
  end
end