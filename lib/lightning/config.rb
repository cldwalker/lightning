class Lightning  
  class Config < ::Hash
    def self.symbolize_keys(hash)
      hash.inject({}) do |h, (key, value)|
        h[key.to_sym] = value; h
      end
    end

    DEFAULT = {:shell=>'bash', :complete_regex=>true, :paths=>{},
      :generated_file=>File.expand_path(File.join('~', '.lightning_completions'))}

    attr_accessor :config_file
    def initialize(hash=read_config_file)
      hash = DEFAULT.merge hash
      super
      replace(hash)
    end
    
    def read_config_file
      self.class.symbolize_keys YAML::load_file(config_file)
    end

    def config_file
      @config_file ||= (File.exists?('lightning.yml') ? 'lightning.yml' :
        File.expand_path(File.join("~",".lightning.yml")))
    end

    def save
      File.open(config_file, "w") { |f| f.puts self.to_yaml }
    end
  end
end