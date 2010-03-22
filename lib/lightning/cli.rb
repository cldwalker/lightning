module Lightning
  # Runs bin/* commands, handling setup and execution.
  module Cli
    @usage = {}
    extend self

    # Used by bin/* to run commands
    def run_command(command, args)
      @command = command.to_sym
      if %w{-h --help}.include?(args[0])
        print_usage
      else
        send("#{command}_command", args)
      end
    rescue StandardError, SyntaxError
      $stderr.puts "Error: "+ $!.message
    end

    # Executes a command with given arguments
    def run(argv=ARGV)
      if argv[0] && commands.include?(argv[0].to_sym)
        run_command(argv.shift, argv)
      elsif %w{-v --version}.include?(argv[0])
        puts VERSION
      else
        puts "Command '#{argv[0]}' not found.","\n" if argv[0] && !%w{-h --help}.include?(argv[0])
        print_help
      end
    end

    # Array of valid commands
    def commands
      @usage.keys
    end

    private
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
      offset = @usage.keys.map {|a| a.to_s.size }.max + 2
      offset += 1 unless offset % 2 == 0
      @usage.sort_by {|e| e.to_s}.each do |command, (usage, desc)|
        puts "  #{command}" << ' ' * (offset - command.to_s.size) << desc.to_s
      end
    end

    def print_usage
      usage_array = Array(@usage[@command])
      usage_array[0] = "Usage: lightning #{@command} #{usage_array[0]}"
      puts usage_array
    end

    def usage(command, *args)
      @usage[command] = args
    end
  end
end