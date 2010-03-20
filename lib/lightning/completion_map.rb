module Lightning
  # Maps completions (file basenames) and aliases to their full paths.
  class CompletionMap
    DUPLICATE_DELIMITER = '//'
    # Regular expression paths to ignore. By default paths ending in . or .. are ignored.
    def self.ignore_paths
      @ignore_paths ||= (Lightning.config[:ignore_paths] || []) + %w{\.\.?$}
    end

    def self.ignore_paths=(val)
      @ignore_paths = val
    end

    attr_accessor :map
    attr_reader :alias_map
    
    def initialize(*globs)
      options = globs[-1].is_a?(Hash) ? globs.pop : {}
      globs.flatten!
      @map = create_globbed_map(globs)
      @alias_map = (Lightning.config[:aliases]).merge(options[:aliases] || {})
    end

    # Look up a full path given a basename
     def [](completion)
       @map[completion] || @alias_map[completion]
     end

     # Lists all unique basenames.
     def keys
       (@map.keys + @alias_map.keys).uniq
     end

    protected
    def create_globbed_map(globs)
      duplicates = {}
      ignore_regexp = /(#{self.class.ignore_paths.join('|')})/
      globs.map {|e| Dir.glob(e, File::FNM_DOTMATCH)}.flatten.uniq.
       inject({}) do |acc, file|
        basename = File.basename file
        next acc if file =~ ignore_regexp
        if duplicates[basename]
          duplicates[basename] << file
        elsif acc.key?(basename)
          duplicates[basename] = [acc.delete(basename), file]
        else
          acc[basename] = file
        end
        acc
       end.merge create_resolved_duplicates(duplicates)
    end

    def create_resolved_duplicates(duplicates)
      duplicates.inject({}) do |hash, (basename, paths)|
        paths.each {|e| hash["#{basename}#{DUPLICATE_DELIMITER}#{File.dirname(e)}"] = e }; hash
      end
    end
  end
end
