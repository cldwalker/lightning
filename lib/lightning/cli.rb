class Lightning
  module Cli
    extend self
    def complete(command, text_to_complete)
      read_config
      (cmd = Lightning.commands[command]) ? Completion.complete(text_to_complete, command) :
        ["#Error: No paths found for this command.", "If this is a bug contact me."]
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