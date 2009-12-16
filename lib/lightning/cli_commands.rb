class Lightning
  module Cli
    usage :complete, "[command] [*arguments]",
      "Prints a command's completions based on the last argument"
    def complete_command(argv)
      return print_usage if argv.empty?
      # this arg is needed by zsh in Complete
      command = argv[0]
      # bash hack: read ENV here because passing $COMP_LINE from the shell
      # is a different incorrect buffer
      buffer = ENV["COMP_LINE"] || argv.join(' ')
      # zsh hack: when tabbing on blank space $@ is empty
      # this ensures all completions
      buffer += " " if argv.size == 1
      puts complete(command, buffer)
    end

    usage :translate, "[command] [*arguments]",
      "Translates each command argument and prints the result"
    def translate_command(argv)
      return print_usage if argv.empty?
      # for one argument do nothing since no translation line was given
      puts translate(argv.shift, argv) if argv.size != 1
    end

    usage :build, "[source_file]", 'Builds a shell file to be sourced based on '+
      '~/.lightning.yml. Uses default file if none given.'
    def build_command(argv)
      read_config
      Builder.can_build? ? Builder.run(argv[0]) :
        puts("No builder exists for #{Builder.shell} shell")
    end

    usage :generate, "[*generators]", "Generates bolts and places them in the config file." +
      " With no arguments, generates default bolts."
    def generate_command(argv=ARGV)
      plugin_file = File.join(Util.find_home, '.lightning.rb')
      load plugin_file if File.exists? plugin_file
      Generator.run(*argv)
    end

    # used internally by commands
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