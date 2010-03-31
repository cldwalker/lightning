require 'yaml'
module Lightning
  # Handles reading and writing of a config file used to generate bolts and commands and offer
  # custom Lightning behavior.
  class Config < ::Hash
    class <<self
      attr_accessor :config_file
      # Defaults to a local lightning.yml if it exists. Otherwise a global ~/.lightning.yml.
      def config_file
        @config_file ||= File.exists?('lightning.yml') ? 'lightning.yml' :
          File.join(Lightning.home,".lightning.yml")
      end
    end

    DEFAULT = {:complete_regex=>true, :bolts=>{}, :shell_commands=>{'cd'=>'cd', 'echo'=>'echo'} }
    def initialize(hash=read_config_file)
      hash = DEFAULT.merge hash
      super
      replace(hash)
    end

    def source_file
      @source_file ||= self[:source_file] || File.join(Lightning.dir, 'functions.sh')
    end

    # Global shell commands used to generate Functions for all Bolts.
    # @return [Hash]
    # Maps shell command names to their aliases using @config[:shell_commands]
    def shell_commands
      self[:shell_commands]
    end

    def create_shell_command(scmd, scmd_alias=nil)
      scmd_alias ||= scmd
      if shell_commands.values.include?(scmd_alias)
        puts "Alias '#{scmd_alias}' already exists for shell command '#{shell_commands.invert[scmd_alias]}'"
      else
        shell_commands[scmd] = scmd_alias
        save_and_say "Added shell command '#{scmd}'"
      end
    end

    def delete_shell_command(scmd)
      if shell_commands[scmd]
        shell_commands.delete scmd
        save_and_say "Deleted shell command '#{scmd}'"
      else
        puts "Can't find shell command '#{scmd}'"
      end
    end

    def bolts
      self[:bolts]
    end

    def create_function(scmd, bolt, options={})
      options[:name] ||= "#{scmd}-#{bolt}"
      if_bolt_found(bolt) {
        func = {'shell_command'=>scmd, 'name'=>options[:name]}
        (bolts[bolt]['add_commands'] ||= []) << func
        save_and_say "Created function '#{options[:name]}'"
      }
    end

    def create_bolt(bolt, globs)
      bolts[bolt] = { 'paths'=>globs.map {|e| e.sub(/^~/, Lightning.home) } }
      save_and_say "Created bolt '#{bolt}'"
    end

    def if_bolt_found(bolt)
      bolts[bolt] ? yield : puts("Can't find bolt '#{bolt}'")
    end

    def alias_bolt(bolt, bolt_alias)
      if_bolt_found(bolt) do
        bolts[bolt]['alias'] = bolt_alias
        save_and_say "Aliased bolt '#{bolt}' to '#{bolt_alias}'"
      end
    end

    def delete_bolt(bolt)
      if_bolt_found(bolt) do
        bolts.delete(bolt)
        save_and_say "Deleted bolt '#{bolt}'"
      end
    end

    def show_bolt(bolt)
      if_bolt_found(bolt) { puts bolts[bolt].to_yaml.sub("--- \n", '') }
    end

    # Saves config to Config.config_file
    def save
      File.open(self.class.config_file, "w") {|f| f.puts Hash.new.replace(self).to_yaml }
    end

    protected
    def save_and_say(message)
      save
      puts message
    end

    def read_config_file
      File.exists?(self.class.config_file) ?
        Util.symbolize_keys(YAML::load_file(self.class.config_file)) : {}
    rescue
      raise $!.message.sub('syntax error', "Syntax error in '#{Config.config_file}'")
    end
  end
end
