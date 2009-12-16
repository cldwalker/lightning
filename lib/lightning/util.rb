class Lightning
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

    # Cross-platform way to determine a user's home. From Rubygems.
    def find_home
      @find_home ||= begin
        ['HOME', 'USERPROFILE'].each {|e| return ENV[e] if ENV[e] }
        return "#{ENV['HOMEDRIVE']}#{ENV['HOMEPATH']}" if ENV['HOMEDRIVE'] && ENV['HOMEPATH']
        File.expand_path("~")
      rescue
        File::ALT_SEPARATOR ? "C:/" : "/"
      end
    end

    # Determines if a shell command exists by searching for it in ENV['PATH'].
    def shell_command_exists?(command)
      (@path ||= ENV['PATH'].split(File::PATH_SEPARATOR)).
        any? {|d| File.exists? File.join(d, command) }
    end

    # Symbolizes keys of given hash
    def symbolize_keys(hash)
      hash.inject({}) do |h, (key, value)|
        h[key.to_sym] = value; h
      end
    end
  end
end