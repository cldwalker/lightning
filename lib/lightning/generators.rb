module Lightning
  # This module contains methods which are used to generate bolts with 'lightning bolt generate'.
  # Each method should return a hash of bolt attributes. A bolt hash should at least have a globs
  # attribute. The name of the method is the name given to the bolt.
  module Generators
    private
    def `(*args)
      cmd = args[0].split(/\s+/)[0] || ''
      if Util.shell_command_exists?(cmd)
        Kernel.`(*args)
      else
        raise "Command '#{cmd}' doesn't exist."
      end
    end

    public
    def self.generators
      (@desc ||= {}).keys
    end

    def self.desc(arg)
      @desc ||= {}
      @next_desc = arg
    end

    def self.method_added(meth)
      @desc[meth.to_s] = @next_desc if @next_desc
      @next_desc = nil
    end
  end
end