class Lightning
  class EntryHash
    def initialize
      @entries = {}
    end
  
    def [](key)
      @entries[key] ||= create_entry(key)
    end
  
    def create_entry(key)
      path_hash = {}
      ignore_paths = ['.', '..'] + Lightning.ignore_paths
      Lightning.paths_for_key(key).each do |d|
        Dir.glob(d, File::FNM_DOTMATCH).each do |e|
          basename = File.basename(e)
          unless ignore_paths.include?(basename)
            #save paths of duplicate basenames to process later
            if path_hash.has_key?(basename)
              if path_hash[basename].is_a?(Array)
                path_hash[basename] << e
              else
                path_hash[basename] = [path_hash[basename], e]
              end
            else
              path_hash[basename] = e
            end
          end
        end
      end
      map_duplicate_basenames(path_hash)
      path_hash
    end
    
    #map saved duplicates
    def map_duplicate_basenames(path_hash)
      path_hash.select {|k,v| v.is_a?(Array)}.each do |key,paths|
        paths.each do |e|
          new_key = "#{key}/#{File.dirname(e)}"
          path_hash[new_key] = e
        end
        path_hash.delete(key)
      end
    end
  end
end