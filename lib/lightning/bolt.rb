module Lightning
  # A bolt is a group of file globs (Dir.glob) used by a Function object
  # to generate a CompletionMap.
  class Bolt
    attr_reader :name, :aliases, :global
    attr_accessor :globs, :functions
    def initialize(name)
      @name = name
      @globs = []
      @functions = []
      @aliases = {}
      (Lightning.config.bolts[@name] || {}).each do |k,v|
        instance_variable_set("@#{k}", v)
      end
    end

    # Generates functions from a bolt's commands and global shell commands
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

    def function_name(scmd)
      Lightning.config.function_name(scmd, alias_or_name)
    end

    protected
    def alias_or_name
      @alias || @name
    end
  end
end
