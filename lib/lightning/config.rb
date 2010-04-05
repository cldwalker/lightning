require 'yaml'
module Lightning
  # Handles config file used to generate bolts and functions and offer custom Lightning behavior.
  class Config < ::Hash
    class <<self
      attr_accessor :config_file
      # @return [String] ~/.lightningrc
      def config_file
        @config_file ||= File.join(Lightning.home,".lightningrc")
      end

      # @return [Hash] Creates a bolt hash given globs
      def bolt(globs)
        {'globs'=>globs.map {|e| e.sub(/^~/, Lightning.home) }}
      end
    end

    DEFAULT = {:complete_regex=>true, :bolts=>{}, :shell_commands=>{'cd'=>'cd', 'echo'=>'echo'} }
    def initialize(hash=read_config_file)
      hash = DEFAULT.merge hash
      super
      replace(hash)
    end

    # @return [String] Shell file generated by Builder. Defaults to ~/.lightning/functions.sh
    def source_file
      @source_file ||= self[:source_file] || File.join(Lightning.dir, 'functions.sh')
    end

    # @return [Array] Global shell commands used to generate Functions for all Bolts.
    def global_commands
      shell_commands.keys
    end

    # @return [Hash] Maps shell command names to their aliases
    def shell_commands
      self[:shell_commands]
    end

    # @return [Hash] Maps bolt names to their config hashes
    def bolts
      self[:bolts]
    end

    # @return [String] Converts shell command alias to shell command
    def unaliased_command(cmd)
      shell_commands.invert[cmd] || cmd
    end

    # @return [String] Converts bolt alias to bolt's name
    def unalias_bolt(bolt)
      bolts[bolt] ? bolt : (Array(bolts.find {|k,v| v['alias'] == bolt })[0] || bolt)
    end

    # @return [String] Extracts shell command from a shell_command string
    def only_command(shell_command)
      shell_command[/\w+/]
    end

    # @return [String] Creates a command name from its shell command and bolt in the form "#{command}-#{bolt}".
    # Uses aliases for either if they exist.
    def function_name(shell_command, bolt)
      cmd = only_command shell_command
      "#{shell_commands[cmd] || cmd}-#{bolt}"
    end

    # Saves config to Config.config_file
    def save
      File.open(self.class.config_file, "w") {|f| f.puts Hash.new.replace(self).to_yaml }
    end

    protected
    def read_config_file
      File.exists?(self.class.config_file) ?
        Util.symbolize_keys(YAML::load_file(self.class.config_file)) : {}
    rescue
      raise $!.message.sub('syntax error', "Syntax error in '#{Config.config_file}'")
    end
  end
end
