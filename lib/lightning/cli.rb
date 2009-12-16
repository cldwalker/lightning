class Lightning
  module Cli
    extend self
    def complete_command(argv=ARGV)
      command = argv[0]
      comp_line = ENV["COMP_LINE"] || argv.join(' ')
      if command
        puts complete(command, comp_line)
      else
        puts "Usage: [command] [*arguments]",
          "Prints a command's completions based on the last argument"
      end
    end

    def translate_command(argv=ARGV)
      if argv.empty?
        puts "Usage: [command] [*arguments]",
          "Translates each command argument and prints the result"
      elsif argv.size == 1
        # Do nothing since no translation line was given
      else
        puts translate(argv.shift, argv)
      end
    end

    def build_command(argv=ARGV)
      if argv.include?('-h') || argv.include?('--help')
        puts "Usage: [source_file]", 'Builds a shell file to be sourced based on '+
          '~/.lightning.yml. Uses default file if none given.'
      else
        read_config
        Builder.can_build? ? Builder.run(argv[0]) :
          puts("No builder exists for #{Builder.shell} shell")
      end
    end

    def generate_command(argv=ARGV)
      if argv.include?('-h') || argv.include?('--help')
        puts "Usage: [*generators]", "Generates bolts and places them in the config file." +
          " With no arguments, generates default bolts."
      else
        plugin_file = File.join(Util.find_home, '.lightning.rb')
        load plugin_file if File.exists? plugin_file
        Generator.run(*argv)
      end
    end

    def complete(command, text_to_complete)
      read_config
      (cmd = Lightning.commands[command]) ? Completion.complete(text_to_complete, cmd) :
        ["#Error: No command found to complete"]
    end

    def translate(command, argv)
      read_config
      (cmd = Lightning.commands[command]) ? cmd.translate_completion(argv) :
        '#Error-no_command_found_to_translate'
    end

    def read_config
      Lightning.config[:bolts].each {|k,v|
        create_commands Lightning.bolts[k].generate_commands
      }
    end

    def create_commands(hash_array)
      hash_array.each {|e| Lightning.commands[e['name']] = Command.new(e) }
    end
  end
end