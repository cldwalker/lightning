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
      Lightning.config_entry(key).each do |d|
        #(Dir.entries(d)- ['.','..']).each do |e|
          #path_array <<  [e, File.join(d,e)]
        Dir.glob(d, File::FNM_DOTMATCH).each do |e|
          basename = File.basename(e)
          path_array << [basename, e] unless Lightning.exceptions.include?(basename)
        end
      end
      Hash[*path_array.flatten]
    end
  end
end