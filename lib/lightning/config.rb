require 'yaml'
class Lightning  
  class Config < ::Hash
    class <<self
      attr_accessor :config_file
      def config_file
        @config_file ||= (File.exists?('lightning.yml') ? 'lightning.yml' :
          File.expand_path(File.join("~",".lightning.yml")))
      end
    end

    DEFAULT = {:complete_regex=>true, :bolts=>{}, :aliases=>{},
      :generated_file=>File.expand_path(File.join('~', '.lightning_completions'))}

    def initialize(hash=read_config_file)
      hash = DEFAULT.merge hash
      super
      replace(hash)
    end
    
    def read_config_file
      Util.symbolize_keys YAML::load_file(self.class.config_file)
    end

    def save
      File.open(self.class.config_file, "w") { |f| f.puts self.to_yaml }
    end
  end
end