#This class maps completions to their full paths for the given blobs
class Lightning
  class CompletionMap
    def self.ignore_paths
      @ignore_paths ||= (Lightning.config[:ignore_paths] || []) + ['.', '..']
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
      @alias_map = (options[:global_aliases] || {}).merge(options[:aliases] || {})
    end
    
     def [](completion)
       @map[completion] || @alias_map[completion]
     end
     
     def keys
       (@map.keys + @alias_map.keys).uniq
     end
    
    def create_globbed_map(globs)
      duplicates = {}
      globs.inject({}) do |acc, glob|
        file_to_basenames = Dir.glob(glob, File::FNM_DOTMATCH).map {|e| [e, File.basename(e)]}
        file_to_basenames.each do |file, basename|
          next if self.class.ignore_paths.include?(basename)
          if duplicates[basename]
            duplicates[basename] << file
          elsif acc.key?(basename)
            duplicates[basename] = [acc.delete(basename), file]
          else
            acc[basename] = file
          end
        end
        acc
      end.merge create_resolved_duplicates(duplicates)
    end
    
    def create_resolved_duplicates(duplicates)
      duplicates.inject({}) do |hash, (basename, paths)|
        paths.each {|e| hash["#{basename}/#{File.dirname(e)}"] = e }; hash
      end
    end
  end
end
