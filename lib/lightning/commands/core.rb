module Lightning
  module Commands
    # Silent command used by `lightning-reload` which prints {Builder}'s shell file
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

    desc "[--file=FILE] [--shell=SHELL]",
      "Builds shell functions and installs them into FILE to be sourced by shell."
    def install(argv)
      args, options = parse_args(argv)
      config[:shell] = options[:shell] if options[:shell]
      config.source_file = options[:file] if options[:file]

      if first_install?
        Generator.run
        puts "Created ~/.lightningrc"
        config.bolts.each {|k,v| v['global'] = true }
        config.save
      end

      Builder.run
      puts "Created #{config.source_file}"+ (first_install? ? " for #{Builder.shell}" : '')
    end

    def first_install?; !File.exists?(Config.config_file); end

    desc '', 'Lists available generators.'
    def generator(argv)
      print_sorted_hash Generator.generators
    end
  end
end