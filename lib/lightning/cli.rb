class Lightning
  module Cli
    extend self
    def complete_command(command, comp_line = ENV["COMP_LINE"] || ARGV.join(' '))
      if command
        puts complete(command, comp_line)
        exit 0
      else
        puts "#No command given"
        exit 1
      end
    end

    def translate_command(argv)
      if argv.size <= 1
        puts "#Not enough arguments given"
        exit 1
      else
        puts translate(argv.shift, argv)
        exit 0
      end
    end

    def generate_command(argv=ARGV)
      Generator.can_generate? ? Generator.run(argv[0]) :
        puts("No generator exists for #{Generator.shell} shell")
    end

    def complete(command, text_to_complete)
      read_config
      (cmd = Lightning.commands[command]) ? Completion.complete(text_to_complete, cmd) :
        ["#Error: No paths found for this command."]
    end

    def translate(command, argv)
      read_config
      (cmd = Lightning.commands[command]) ? cmd.translate_completion(argv) :
        '#Error-no_paths_found_for_this_command'
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