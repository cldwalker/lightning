class Lightning
  module Cli
    USAGE = {}
    extend self

    def run_command(command, argv=ARGV)
      @command = command
      if argv.include?('-h') || argv.include?('--help')
        print_usage
      else
        send("#{command}_command", argv)
      end
    rescue StandardError, SyntaxError
      $stderr.puts "Error: "+ $!.message
    end

    def print_usage
      usage_array = Array(USAGE[@command])
      usage_array[0] = "Usage: #{usage_array[0]}"
      puts usage_array
    end

    def usage(command, *args)
      USAGE[command] = args
    end
  end
end