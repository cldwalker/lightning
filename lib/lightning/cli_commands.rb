module Lightning
  module Cli
    usage 'complete', "COMMAND [arguments]",
      "Prints a command's completions based on the last argument."
    # Runs lightning complete
    def complete_command(argv)
      return print_command_help if argv.empty?
      # this arg is needed by zsh in Complete
      function = argv[0]
      # bash hack: read ENV here because passing $COMP_LINE from the shell
      # is a different incorrect buffer
      buffer = ENV["COMP_LINE"] || argv.join(' ')
      # zsh hack: when tabbing on blank space $@ is empty
      # this ensures all completions
      buffer += " " if argv.size == 1
      puts complete(function, buffer)
    end

    usage 'translate', "COMMAND [arguments]",
      "Translates each argument and prints it on a separate line."
    # Runs lightning translate
    def translate_command(argv)
      return print_command_help if argv.empty?
      # for one argument do nothing since no translation line was given
      puts translate(argv.shift, argv) if argv.size != 1
    end

    usage 'install', "[--generators=GENERATORS] [--source_file=SOURCE_FILE] [--shell=SHELL]",
      "Optionally builds a config file and then builds a SOURCE_FILE from the config file."
    # Runs lightning install
    def install_command(argv)
      first_install = !File.exists?(Lightning::Config.config_file)
      args, options = parse_args(argv)
      Generator.run(options[:generators]) if first_install || options[:generators]
      puts "Created ~/.lightning.yml" if first_install

      Lightning.config[:shell] = options[:shell] if options[:shell]
      Builder.run(options[:source_file])
      puts "Created #{Lightning.config[:source_file]}"
    end

    usage 'bolt', "(list [-a|--alias] | add BOLT GLOBS | alias BOLT ALIAS | "+
      "delete BOLT | generate BOLT [generator] [-t|--test] | show BOLT)",
      "Commands for managing bolts. Defaults to listing them."
    def bolt_command(argv)
      subcommand = argv.shift || 'list'
      subcommand = %w{add alias delete generate list show}.find {|e| e[/^#{subcommand}/]} || subcommand
      bolt_subcommand(subcommand, argv) if subcommand_has_required_args(subcommand, argv)
    end

    usage 'shell_command',
      '(list [-a|--alias] | add SHELL_COMMAND [alias]| delete SHELL_COMMAND)',
      'Commands for managing shell commands. Defaults to listing them.'
    def shell_command_command(argv)
      subcommand = argv.shift || 'list'
      subcommand = %w{add delete list}.find {|e| e[/^#{subcommand}/]} || subcommand
      shell_command_subcommand(subcommand, argv) if subcommand_has_required_args(subcommand, argv)
    end

    usage 'functions', '', 'Lists functions generated from shell_commands and bolts.'
    def functions_command(argv)
      Lightning.setup
      puts Lightning.functions.keys.sort
    end

    usage 'generators', '', 'Lists available generators.'
    def generators_command(argv)
      puts Generator.generators.sort
    end

    def source_file_command(argv)
      puts Lightning.config[:source_file]
    end

    protected
    def shell_command_subcommand(subcommand, argv)
      case subcommand
      when 'list'   then   list_subcommand(:shell_commands, argv)
      when 'add'    then   Lightning.config.add_shell_command(argv[0], argv[1])
      when 'delete' then   Lightning.config.delete_shell_command(argv[0])
      else  puts "Invalid subcommand '#{subcommand}'", command_usage
      end
    end

    def bolt_subcommand(subcommand, argv)
      case subcommand
      when 'list'     then    list_subcommand(:bolts, argv)
      when 'add'      then    Lightning.config.add_bolt(argv.shift, argv)
      when 'alias'    then    Lightning.config.alias_bolt(argv[0], argv[1])
      when 'delete'   then    Lightning.config.delete_bolt(argv[0])
      when 'show'     then    Lightning.config.show_bolt(argv[0])
      when 'generate'
        Generator.run(argv[0], :once=>argv[1], :test=>!(argv & %w{-t --test}).empty?)
      else puts "Invalid subcommand '#{subcommand}'", command_usage
      end
    end

    def list_subcommand(list_type, argv)
      if %w{-a --alias}.include?(argv[0])
        puts Lightning.config.send(list_type).keys.sort.map {|e|
          list_type == :shell_commands ?
            "#{e}: #{Lightning.config.send(list_type)[e]}" :
            "#{e}: #{Lightning.config.send(list_type)[e]['alias']}"
        }
      else
        puts Lightning.config.send(list_type).keys.sort
      end
    end

    def complete(function, text_to_complete)
      Lightning.setup
      Completion.complete(text_to_complete, Lightning.functions[function])
    end

    def translate(function, argv)
      Lightning.setup
      (cmd = Lightning.functions[function]) ? cmd.translate_completion(argv) :
        '#Error-no_function_found_to_translate'
    end
  end
end
