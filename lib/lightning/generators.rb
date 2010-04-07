module Lightning
  # This module contains methods which are used to generate bolts with 'lightning bolt generate'.
  # Each method should return an array of bolt globs. The name of the method is the name given to the bolt.
  #
  # == Generator Plugins
  # Generator plugins are a way for users to define and share generators.
  # A generator plugin is a .rb file in ~/.lightning/generators/. Each plugin can have multiple
  # generators since a generator is just a method in Lightning::Generators.
  #
  # A sample generator plugin looks like this:
  #   module Lightning::Generators
  #     desc "Files in $PATH"
  #     def bin
  #       ENV['PATH'].split(":").uniq.map {|e| "#{e}/*" }
  #     end
  #   end
  #
  # To register a generator, {Generators.desc desc} must be placed before a method and given a generator
  # description. A generator should produce an array of globs. If a generator is to be shared with others
  # it should dynamically generate filesystem-specific globs based on environment variables and commands.
  # Generated globs don't have to expand '~' as lightning expands that automatically to the user's home.
  #
  # For generator plugin examples
  # {read the source}[http://github.com/cldwalker/lightning/tree/master/lib/lightning/generators/].
  module Generators
    # @return [Hash] Maps generators to their descriptions
    def self.generators
      @desc ||= {}
    end

    # Used before a generator method to give it a description
    def self.desc(arg)
      @next_desc = arg
    end

    # Overridden for generators to error elegantly when a generator calls a shell command that
    # doesn't exist
    def `(*args)
      cmd = args[0].split(/\s+/)[0] || ''
      if Util.shell_command_exists?(cmd)
        Kernel.`(*args)
      else
        raise "Command '#{cmd}' doesn't exist."
      end
    end

    private
    def self.method_added(meth)
      generators[meth.to_s] = @next_desc if @next_desc
      @next_desc = nil
    end
  end
end