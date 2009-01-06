require File.join(File.dirname(__FILE__), 'completion')
require 'yaml'

# Supplies path completions under directories specified by a config key for path_completions.yml.
class PathCompletion < Completion
  class<<self; attr_accessor :config_key; end

  def possible_completions
    dirs = directories_for_config_key(self.class.config_key)
    dirs.map {|e| Dir.entries(e)}.flatten.uniq - ['.','..']
#    fullnames = dirs.map {|e| Dir.glob(e)}.flatten.uniq - ['.','..']
#    fullnames.map {|e| File.basename(e) }
  end

  def directories_for_config_key(key)
    config_yaml_file = File.join(File.dirname(__FILE__), "path_completions.yml")
    YAML::load(File.new(config_yaml_file))[key]
  end

end
