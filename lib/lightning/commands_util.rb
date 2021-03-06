module Lightning
  # Utility methods to be used inside lightning commands.
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

    # Handles abbreviated subcommands and printing errors for invalid subcommands.
    # Defaults to 'list' subcommand if none given.
    def call_subcommand(argv, cmds)
      subcommand = argv.shift || 'list'
      (subcmd = cmds.find {|e| e[/^#{subcommand}/]}) ?
        subcommand_has_required_args(subcmd, argv) && yield(subcmd, argv) :
        puts("Invalid subcommand '#{subcommand}'", command_usage)
    end

    # @return [nil, true] Determines if command has required arguments
    def command_has_required_args(argv, required)
      return true if argv.size >= required
      puts "'lightning #{@command}' was called incorrectly.", command_usage
    end

    # Parses arguments into non-option arguments and hash of options. Options can have
    # values with an equal sign i.e. '--option=value'. Options can be abbreviated with
    # their first letter. Options without a value are set to true.
    # @param [Array]
    # @return [Array<Array, Hash>] Hash of options has symbolic keys
    def parse_args(args, names=[])
      options, args = args.partition {|e| e =~ /^-/ }
      options = options.inject({}) do |hash, flag|
        key, value = flag.split('=')
        name = key.sub(/^--?/,'')
        name = names.sort.find {|e| e[/^#{name}/] } || name
        hash[name.intern] = value.nil? ? true : value
        hash
      end
      [args, options]
    end

    # Shortcut to Lightning.config
    def config; Lightning.config; end

    private
    def subcommand_has_required_args(subcommand, argv)
      return true if argv.size >= (subcommand_required_args[subcommand] || 0)
      puts "'lightning #{@command} #{subcommand}' was called incorrectly.", command_usage
    end

    def subcommand_required_args
      desc_array[0].split('|').inject({}) {|a,e|
        cmd, *args = e.strip.split(/\s+/)
        a[cmd] = args.select {|e| e[/^[A-Z]/]}.size
        a
      }
    end
  end
end