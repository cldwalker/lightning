module Lightning
  module Commands
    meta "FUNCTION [arguments]", "Prints a function's completions based on the last argument."
    # Runs lightning complete
    def complete(argv)
      return unless command_has_required_args(argv, 1)
      # this arg is needed by zsh in Complete
      function = argv[0]
      # bash hack: read ENV here because passing $COMP_LINE from the shell
      # is a different incorrect buffer
      buffer = ENV["COMP_LINE"] || argv.join(' ')
      # zsh hack: when tabbing on blank space $@ is empty
      # this ensures all completions
      buffer += " " if argv.size == 1
      puts _complete(function, buffer)
    end

    meta "FUNCTION ARGUMENTS", "Translates each argument and prints it on a separate line."
    # Runs lightning translate
    def translate(argv)
      return unless command_has_required_args(argv, 2)
      puts _translate(argv.shift, argv)
    end

    meta "[--generators=GENERATORS] [--source_file=SOURCE_FILE] [--shell=SHELL]",
      "Optionally builds a config file and then builds a SOURCE_FILE from the config file."
    # Runs lightning install
    def install(argv)
      first_install = !File.exists?(Config.config_file)
      args, options = parse_args(argv)
      Generator.run(options[:generators]) if first_install || options[:generators]
      puts "Created ~/.lightning.yml" if first_install

      Lightning.config[:shell] = options[:shell] if options[:shell]
      Builder.run(options[:source_file])
      puts "Created #{Lightning.config.source_file}"
    end

    meta '', 'Lists available generators.'
    def generator(argv)
      print_sorted_hash Generator.generators
    end

    # silent command needed for lightning-reload
    def source_file(argv)
      puts Lightning.config.source_file
    end

    protected
    def _complete(function, text_to_complete)
      Lightning.setup
      Completion.complete(text_to_complete, Lightning.functions[function])
    end

    def _translate(function, argv)
      Lightning.setup
      (cmd = Lightning.functions[function]) ? cmd.translate_completion(argv) :
        '#Error-no_function_found_to_translate'
    end
  end
end