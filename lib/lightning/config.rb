require 'yaml'
class Lightning
  # Handles reading and writing of a config file used to generate bolts and commands and offer
  # custom Lightning behavior.
  class Config < ::Hash
    class <<self
      attr_accessor :config_file
      # Defaults to a local lightning.yml if it exists. Otherwise a global ~/.lightning.yml.
      def config_file
        @config_file ||= File.exists?('lightning.yml') ? 'lightning.yml' :
          File.join(Util.find_home,".lightning.yml")
      end
    end

    DEFAULT = {:complete_regex=>true, :bolts=>{}, :aliases=>{},
      :source_file=>File.join(Util.find_home, '.lightning_completions') }

    def initialize(hash=read_config_file)
      hash = DEFAULT.merge hash
      super
      replace(hash)
    end

    # Global shell commands used to generate Commands for all Bolts.
    # @return [Hash]
    # Maps shell command names to their aliases. Generated from the
    # config[:shell_commands] array.
    def shell_commands
      @shell_commands ||= begin
        (self[:shell_commands] || []).inject({}) {|a,e|
          e.is_a?(Hash) ? a.merge!(e) : a.merge!(e=>e)
        }
      end
    end

    # Saves config to Config.config_file
    def save
      File.open(self.class.config_file, "w") {|f| f.puts Hash.new.replace(self).to_yaml }
    end

    protected
    def read_config_file
      Util.symbolize_keys YAML::load_file(self.class.config_file)
    end
  end
end