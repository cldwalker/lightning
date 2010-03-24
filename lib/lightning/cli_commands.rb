module Lightning
  module Cli
    usage 'complete', "COMMAND [arguments]",
      "Prints a command's completions based on the last argument."
    # Runs lightning complete
    def complete_command(argv)
      return print_command_help if argv.empty?
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

    usage 'translate', "COMMAND [arguments]",
      "Translates each argument and prints it on a separate line."
    # Runs lightning translate
    def translate_command(argv)
      return print_command_help if argv.empty?
      # for one argument do nothing since no translation line was given
      puts translate(argv.shift, argv) if argv.size != 1
    end

    usage 'build', "[source_file]", 'Builds a shell file to be sourced based on '+
      '~/.lightning.yml. Uses default file if none given.'
    # Runs lightning build
    def build_command(argv)
      Lightning.setup
      Builder.can_build? ? Builder.run(argv[0]) :
        puts("No builder exists for #{Builder.shell} shell")
    end

    usage 'install', "[generators]", "Installs lightning for first-time users. " +
      "Bolts are generated with default generators if none given."
    # Runs lightning install
    def install_command(argv)
      Generator.run(*argv)
      puts "Created ~/.lightning.yml"
      build_command([])
      puts "Created #{Lightning.config[:source_file]}"
    end

    usage 'bolt',
      "(list | add BOLT GLOBS | alias BOLT ALIAS | delete BOLT | generate BOLT [generator] | show BOLT)",
      "Commands for managing bolts. Defaults to listing them."
    def bolt_command(argv)
      subcommand = argv.shift || 'list'
      subcommand = %w{add alias delete generate list show}.find {|e| e[/^#{subcommand}/]} || subcommand
      bolt_subcommand(subcommand, argv) if subcommand_has_required_args(subcommand, argv)
    end

    usage 'shell_command',
      '(list | add SHELL_COMMAND [alias]| delete SHELL_COMMAND)',
      'Commands for managing shell commands. Defaults to listing them.'
    def shell_command_command(argv)
      subcommand = argv.shift || 'list'
      subcommand = %w{add delete list}.find {|e| e[/^#{subcommand}/]} || subcommand
      shell_command_subcommand(subcommand, argv) if subcommand_has_required_args(subcommand, argv)
    end

    usage 'commands', '', 'Lists commands generated from shell_commands and bolts.'
    def commands_command(argv)
      Lightning.setup
      puts Lightning.commands.keys.sort
    end

    usage 'generators', '', 'Lists available generators.'
    def generators_command(argv)
      Generator.setup
      puts Generator.generators.sort
    end

    protected
    def shell_command_subcommand(subcommand, argv)
      case subcommand
      when 'list'   then   puts Lightning.config.shell_commands.keys.sort
      when 'add'    then   Lightning.config.add_shell_command(argv[0], argv[1])
      when 'delete' then   Lightning.config.delete_shell_command(argv[0])
      else
        puts "Invalid subcommand '#{subcommand}'", ''
        print_command_help
      end
    end

    def bolt_subcommand(subcommand, argv)
      case subcommand
      when 'list'     then    puts Lightning.config.bolts.keys.sort
      when 'add'      then    Lightning.config.add_bolt(argv.shift, argv)
      when 'alias'    then    Lightning.config.alias_bolt(argv[0], argv[1])
      when 'delete'   then    Lightning.config.delete_bolt(argv[0])
      when 'generate' then    Generator.run_once(argv[0], argv[1])
      when 'show'     then    Lightning.config.show_bolt(argv[0])
      else
        puts "Invalid subcommand '#{subcommand}'", ''
        print_command_help
      end
    end

    def complete(command, text_to_complete)
      Lightning.setup
      Completion.complete(text_to_complete, Lightning.commands[command])
    end

    def translate(command, argv)
      Lightning.setup
      (cmd = Lightning.commands[command]) ? cmd.translate_completion(argv) :
        '#Error-no_command_found_to_translate'
    end
  end
end