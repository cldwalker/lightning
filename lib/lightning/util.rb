module Lightning
  module Util
    extend self

    if RUBY_VERSION < '1.9.1'

      # From Ruby 1.9's Shellwords#shellescape
      def shellescape(str)
        # An empty argument will be skipped, so return empty quotes.
        return "''" if str.empty?

        str = str.dup

        # Process as a single byte sequence because not all shell
        # implementations are multibyte aware.
        str.gsub!(/([^A-Za-z0-9_\-.,:\/@\n])/n, "\\\\\\1")

        # A LF cannot be escaped with a backslash because a backslash + LF
        # combo is regarded as line continuation and simply ignored.
        str.gsub!(/\n/, "'\n'")

        return str
      end
    else

      require 'shellwords'
      def shellescape(str)
        Shellwords.shellescape(str)
      end
    end

    # @return [String] Cross-platform way to determine a user's home. From Rubygems.
    def find_home
      ['HOME', 'USERPROFILE'].each {|e| return ENV[e] if ENV[e] }
      return "#{ENV['HOMEDRIVE']}#{ENV['HOMEPATH']}" if ENV['HOMEDRIVE'] && ENV['HOMEPATH']
      File.expand_path("~")
    rescue
      File::ALT_SEPARATOR ? "C:/" : "/"
    end

    # @return [Boolean] Determines if a shell command exists by searching for it in ENV['PATH'].
    def shell_command_exists?(command)
      (@path ||= ENV['PATH'].split(File::PATH_SEPARATOR)).
        any? {|d| File.exists? File.join(d, command) }
    end

    # @return [Hash] Symbolizes keys of given hash
    def symbolize_keys(hash)
      hash.inject({}) do |h, (key, value)|
        h[key.to_sym] = value; h
      end
    end

    # Loads *.rb plugins in given directory and sub directory under it
    def load_plugins(base_dir, sub_dir)
      if File.exists?(dir = File.join(base_dir, sub_dir))
        plugin_type = sub_dir.sub(/s$/, '')
        Dir[dir + '/*.rb'].each {|file| load_plugin(file, plugin_type) }
      end
    end

    protected
    def load_plugin(file, plugin_type)
      require file
    rescue Exception => e
      puts "Error: #{plugin_type.capitalize} plugin '#{File.basename(file)}'"+
        " failed to load:", e.message
    end
  end
end