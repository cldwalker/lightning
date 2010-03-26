module Lightning
  module Commands
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
      first_install = !File.exists?(Config.config_file)
      args, options = parse_args(argv)
      Generator.run(options[:generators]) if first_install || options[:generators]
      puts "Created ~/.lightning.yml" if first_install

      Lightning.config[:shell] = options[:shell] if options[:shell]
      Builder.run(options[:source_file])
      puts "Created #{Lightning.config[:source_file]}"
    end

    protected
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