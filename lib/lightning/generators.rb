module Lightning
  # This module contains methods which are used to generate bolts with 'lightning bolt generate'.
  # Each method should return a hash of bolt attributes. A bolt hash should at least have a globs
  # attribute. The name of the method is the name given to the bolt.
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