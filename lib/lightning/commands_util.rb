module Lightning
  # Utility methods to be used inside commands
  module CommandsUtil
    # Yields a block for an existing bolt or prints an error message
    def if_bolt_found(bolt)
      bolt = config.unalias_bolt(bolt)
      config.bolts[bolt] ? yield(bolt) : puts("Can't find bolt '#{bolt}'")
    end

    # Prints a hash as a 2 column table sorted by keys
    def print_sorted_hash(hash, indent=false)
      offset = hash.keys.map {|e| e.size }.max + 2
      offset += 1 unless offset % 2 == 0
      indent_char = indent ? '  ' : ''
      hash.sort.each do |k,v|
        puts "#{indent_char}#{k}" << ' ' * (offset - k.size) << (v || '')
      end
    end

    # Saves config and prints message
    def save_and_say(message)
      config.save
      puts message
    end

    # @return [nil, true] Determines if command has required arguments
    def command_has_required_args(argv, required)
      return true if argv.size >= required
      puts "'lightning #{@command}' was called incorrectly.", command_usage
    end

    # @return [nil, true] Determines if subcommand has required arguments
    def subcommand_has_required_args(subcommand, argv)
      return true if argv.size >= (subcommand_required_args[subcommand] || 0)
      puts "'lightning #{@command} #{subcommand}' was called incorrectly.", command_usage
    end

    # Parses arguments into non-option arguments and hash of options. Options can have
    # values with an equal sign i.e. '--option=value'. Options without a value are set to true.
    # @param [Array]
    # @return [Array<Array, Hash>] Hash of options has symbolic keys
    def parse_args(args)
      options, args = args.partition {|e| e =~ /^-/ }
      options = options.inject({}) do |hash, flag|
        key, value = flag.split('=')
        value = true if value.nil?
        hash[key.sub(/^--?/,'').intern] = value.to_s[/,/] ? value.split(',') : value
        hash
      end
      [args, options]
    end

    # Shortcut to Lightning.config
    def config; Lightning.config; end

    # Lists a bolt or shell_command with optional --alias
    def list_subcommand(list_type, argv)
      if %w{-a --alias}.include?(argv[0])
        hash = config.send(list_type)
        hash = hash.inject({}) {|a,(k,v)| a[k] = v['alias']; a } if list_type == :bolts
        print_sorted_hash hash
      else
        puts config.send(list_type).keys.sort
      end
    end

    private
    def subcommand_required_args
      desc_array[0].split('|').inject({}) {|a,e|
        cmd, *args = e.strip.split(/\s+/)
        a[cmd] = args.select {|e| e[/^[A-Z]/]}.size
        a
      }
    end
  end
end