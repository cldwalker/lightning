class Lightning  
  class Config < ::Hash
    DEFAULT = {'shell'=>'bash', 'complete_regex'=>true, 'paths'=>{},
      'generated_file'=>File.expand_path(File.join('~', '.lightning_completions'))}

    attr_accessor :config_file
    def initialize(hash=read_config_file)
      hash = DEFAULT.merge hash
      super
      replace(hash)
      self.replace(self.symbolize_keys)
    end
    
    def read_config_file
      YAML::load_file(config_file)
    end

    def config_file
      @config_file ||= (File.exists?('lightning.yml') ? 'lightning.yml' :
        File.expand_path(File.join("~",".lightning.yml")))
    end

    def save
      File.open(config_file, "w") { |f| f.puts self.to_yaml }
    end

    #from Rails' ActiveSupport
    def symbolize_keys
      inject({}) do |options, (key, value)|
        options[key.to_sym] = value
        options
      end
    end
  end
end