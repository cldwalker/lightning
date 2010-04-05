module Lightning
  # Runs lightning commands.
  module Commands
    @meta = {}
    extend self

    # Called by `lightning` to call proper lightning command, print help or print version
    def run(argv=ARGV)
      if (command = argv.shift) && (actual_command = unalias_command(command))
        run_command(actual_command, argv)
      elsif command && respond_to?(command)
        run_command(command, argv)
      elsif %w{-v --version}.include?(command)
        puts "lightning #{VERSION}"
      else
        load_user_commands
        puts "Command '#{command}' not found.","\n" if command && !%w{-h --help}.include?(command)
        print_help
      end
    end

    # @return [Array] Available lightning commands
    def commands
      @meta.keys
    end

    # Calls proper lightning command with remaining commandline arguments
    def run_command(command, args)
      @command = command.to_s
      if %w{-h --help}.include?(args[0])
        print_command_help
      else
        send(command, args)
      end
    rescue StandardError
      $stderr.puts "Error: "+ $!.message
    end

    # @return [nil, true] Command helper to determine if subcommand has required arguments
    def subcommand_has_required_args(subcommand, argv)
      return true if argv.size >= (subcommand_required_args[subcommand] || 0)
      puts "'lightning #{@command} #{subcommand}' was called incorrectly.", command_usage
    end

    # @return [nil, true] Command helper to determine if command has required arguments
    def command_has_required_args(argv, required)
      return true if argv.size >= required
      puts "'lightning #{@command}' was called incorrectly.", command_usage
    end

    # Command helper to print a hash as a 2 column table sorted by keys
    def print_sorted_hash(hash, indent=false)
      offset = hash.keys.map {|e| e.size }.max + 2
      offset += 1 unless offset % 2 == 0
      indent_char = indent ? '  ' : ''
      hash.sort.each do |k,v|
        puts "#{indent_char}#{k}" << ' ' * (offset - k.size) << (v || '')
      end
    end

    # Command helper which saves config and prints message
    def save_and_say(message)
      config.save
      puts message
    end

    # Command helper which yields a block for an existing bolt or prints an error message
    def if_bolt_found(bolt)
      bolt = config.unalias_bolt(bolt)
      config.bolts[bolt] ? yield(bolt) : puts("Can't find bolt '#{bolt}'")
    end

    # @return [String] Command usage for current command
    def command_usage
      "Usage: lightning #{@command} #{meta_array[0]}"
    end

    # Placed before a command method to set its usage and description
    def meta(*args)
      @next_meta = args
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

    # Command helper which is just a shortcut to Lightning.config
    def config; Lightning.config; end

    private
    def print_command_help
      puts [command_usage, '', meta_array[1]]
    end

    def list_subcommand(list_type, argv)
      if %w{-a --alias}.include?(argv[0])
        hash = config.send(list_type)
        hash = hash.inject({}) {|a,(k,v)| a[k] = v['alias']; a } if list_type == :bolts
        print_sorted_hash hash
      else
        puts config.send(list_type).keys.sort
      end
    end

    def print_help
      puts "lightning COMMAND [arguments]", ""
      puts "Available commands:"
      print_sorted_hash @meta.inject({}) {|a,(k,v)| a[k] = v[1]; a }, true
      puts "", "For more information on a command use:"
      puts "  lightning COMMAND -h", ""
      puts "Options: "
      puts "  -h, --help     Show this help and exit"
      puts "  -v, --version  Print current version and exit"
      puts "", "Commands and subcommands can be abbreviated."
      puts "For example, 'lightning b c gem path1' is short for 'lightning bolt create gem path1'."
    end

    def meta_array
      Array(@meta[@command])
    end

    def unalias_command(command)
      actual_command = commands.sort.find {|e| e[/^#{command}/] }
      # don't load plugin commands for faster completion/translation
      load_user_commands unless %w{translate complete}.include?(actual_command)
      actual_command || commands.sort.find {|e| e[/^#{command}/] }
    end

    def load_user_commands
      @load_user_commands ||= Util.load_plugins(Lightning.dir, 'commands') || true
    end

    def subcommand_required_args
      meta_array[0].split('|').inject({}) {|a,e|
        cmd, *args = e.strip.split(/\s+/)
        a[cmd] = args.select {|e| e[/^[A-Z]/]}.size
        a
      }
    end

    def method_added(meth)
      @meta[meth.to_s] = @next_meta if @next_meta
      @next_meta = nil
    end
  end
end

Lightning::Util.load_plugins File.dirname(__FILE__), 'commands'