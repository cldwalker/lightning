module Lightning
  # A Bolt object is a user-defined set of globs that a Function object needs to translate paths.
  class Bolt
    # @return [String] Unique alphanumeric name
    attr_reader :name
    # @return [Hash] Maps aliases to full paths. Aliases are valid for a bolt's functions
    attr_reader :aliases
    # @return [Boolean] When true adds global commands to list of commands used to generate a bolt's functions
    attr_reader :global
    # @return [Array] User-defined globs that are translated by Dir.glob().
    attr_accessor :globs
    # Used to generate functions.
    # @return [Array<Hash, String>] An array element can be a hash of function attributes or a shell command
    attr_accessor :functions
    def initialize(name)
      @name = name
      @globs = []
      @functions = []
      @aliases = {}
      (Lightning.config.bolts[@name] || {}).each do |k,v|
        instance_variable_set("@#{k}", v)
      end
    end

    # Generates functions from a bolt's functions and global shell commands
    # @return [Array]
    def generate_functions
      @functions += Lightning.config.global_commands if @global
      @functions.inject({}) {|acc, e|
        cmd = e.is_a?(Hash) ? e.dup : {'shell_command'=>e}
        cmd['bolt'] = self
        cmd['name'] ||= function_name(cmd['shell_command'])
        acc[cmd['name']] ||= cmd if cmd['shell_command']
        acc
      }.values
    end

    # Creates function name for a bolt given a shell command
    def function_name(scmd)
      Lightning.config.function_name(scmd, alias_or_name)
    end

    protected
    def alias_or_name
      @alias || @name
    end
  end
end
