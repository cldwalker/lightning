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
        print_global_usage
      end
    end

    # Array of valid commands
    def commands
      @usage.keys
    end

    private
    def print_global_usage
      puts "lightning [command] [arguments]"
    end

    def print_usage
      usage_array = Array(@usage[@command])
      usage_array[0] = "Usage: #{usage_array[0]}"
      puts usage_array
    end

    def usage(command, *args)
      @usage[command] = args
    end
  end
end