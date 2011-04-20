module Lightning
  # A Bolt object is mainly a user-defined set of globs required by a {Function} object to translate paths.
  #
  # == Globs
  # Globs are interpreted by Dir.glob and are fairly similar to shell globs. Some glob examples:
  #
  # * Files ending with specific file extensions for a given directory.
  #    "/some/path/*.{rb,erb}"-> Matches files ending with .rb or .erb
  #
  # * Files and directories that don't start with specific letters.
  #    "[^ls]*" -> Matches anything not starting with l or s
  #
  # * All directories, however many levels deep, under the current directory.
  #    "**/"
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
      config = Lightning.config.bolts[@name] || {}
      config.each { |k,v| instance_variable_set("@#{k}", v) }
      @globs = Generator.run(@name, :live => true) unless config.key?('globs')
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
