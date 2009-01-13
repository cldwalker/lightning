class Lightning
  class EntryHash
    def initialize
      @entries = {}
    end
  
    def [](key)
      @entries[key] ||= create_entry(key)
    end
  
    def create_entry(key)
      path_array = []
      ignore_paths = ['.', '..'] + Lightning.ignore_paths
      Lightning.paths_for_key(key).each do |d|
        Dir.glob(d, File::FNM_DOTMATCH).each do |e|
          basename = File.basename(e)
          path_array << [basename, e] unless ignore_paths.include?(basename)
        end
      end
      Hash[*path_array.flatten]
    end
  end
end