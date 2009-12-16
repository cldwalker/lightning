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
    end

    def print_usage
      puts USAGE[@command]
    end

    def usage(command, *args)
      USAGE[command] = args
    end
  end
end