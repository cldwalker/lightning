require 'path_completion'
require 'yaml'

module Lightning
  VERSION = '0.1.0'
  class<<self
    def config_key(key)
      config_yaml_file = File.join(File.dirname(__FILE__), "../lightning.yml")
      YAML::load(File.new(config_yaml_file))[key]
    end
    
    def path_hash(key)
      @path_hash ||= {}
      @path_hash[key] ||= make_path_hash(key)
    end
    
    def make_path_hash(key)
      path_array = []
      exceptions = ['.', '..']
      config_key(key).each do |d|
        #(Dir.entries(d)- ['.','..']).each do |e|
          #path_array <<  [e, File.join(d,e)]
        Dir.glob(d, File::FNM_DOTMATCH).each do |e|
          basename = File.basename(e)
          path_array << [basename, e] unless exceptions.include?(basename)
        end
      end
      Hash[*path_array.flatten]
    end
    
    def entries_for_key(key)
      path_hash(key).keys
    end
    
    def possible_completions(text, key)
      PathCompletion.config_key = key
      PathCompletion.new(ENV["COMP_LINE"]).matches
    end
    
    def full_path_for_completion(basename, key)
      path_hash(key)[basename]
    end
  end
end