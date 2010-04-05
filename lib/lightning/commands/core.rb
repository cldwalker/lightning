module Lightning
  module Commands
    # Silent command used by `lightning-reload` which prints Builder's shell file
    def source_file(argv)
      puts config.source_file
    end

    protected
    desc "FUNCTION [arguments]", "Prints a function's completions based on the last argument."
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

      puts Completion.complete(buffer, Lightning.functions[function])
    end

    desc "FUNCTION ARGUMENTS", "Translates each argument and prints it on a separate line."
    def translate(argv)
      return unless command_has_required_args(argv, 2)
      translations = (fn = Lightning.functions[argv.shift]) ?
        fn.translate(argv).join("\n") : '#Error-no_function_found_to_translate'
      puts translations
    end

    desc "[--generators=GENERATORS] [--source_file=SOURCE_FILE] [--shell=SHELL]",
      "Optionally builds a config file and then builds a SOURCE_FILE from the config file."
    def install(argv)
      first_install = !File.exists?(Config.config_file)
      args, options = parse_args(argv)
      Generator.run(options[:generators]) if first_install || options[:generators]
      puts "Created ~/.lightningrc" if first_install

      config[:shell] = options[:shell] if options[:shell]
      Builder.run(options[:source_file])
      puts "Created #{config.source_file}"
    end

    desc '', 'Lists available generators.'
    def generator(argv)
      print_sorted_hash Generator.generators
    end
  end
end