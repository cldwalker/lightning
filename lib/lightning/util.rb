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

    # From Rubygems, determine a user's home.
    def find_home
      ['HOME', 'USERPROFILE'].each {|e| return ENV[e] if ENV[e] }
      return "#{ENV['HOMEDRIVE']}#{ENV['HOMEPATH']}" if ENV['HOMEDRIVE'] && ENV['HOMEPATH']
      File.expand_path("~")
    rescue
      File::ALT_SEPARATOR ? "C:/" : "/"
    end

    def symbolize_keys(hash)
      hash.inject({}) do |h, (key, value)|
        h[key.to_sym] = value; h
      end
    end
  end
end