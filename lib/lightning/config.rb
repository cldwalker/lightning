class Lightning  
  class Config < ::Hash
    attr_accessor :config_file
    def initialize(hash=nil)
      hash ||= read_config_file
      hash[:paths] ||= {}
      super
      replace(hash)
      self.replace(self.symbolize_keys)
    end
    
    def config_file
      @config_file ||= (File.exists?('lightning.yml') ? 'lightning.yml' : File.expand_path(File.join("~",".lightning.yml")))
    end

    def read_config_file(file=nil)
      default_config = {'shell'=>'bash', 'generated_file'=>File.expand_path(File.join('~', '.lightning_completions')),
        'complete_regex'=>true}
      @config_file = file if file
      hash = YAML::load_file(config_file)
      default_config.merge(hash)
    end

    def to_hash
      hash = Hash.new
      hash.replace(self)
    end
    
    def save
      File.open(config_file, "w") { |f| f.puts self.to_hash.to_yaml }
    end

    #from Rails' ActiveSupport
    def symbolize_keys
      inject({}) do |options, (key, value)|
        options[(key.to_sym rescue key) || key] = value
        options
      end
    end
    
  end
end