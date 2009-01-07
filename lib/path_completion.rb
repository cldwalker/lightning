require File.join(File.dirname(__FILE__), 'completion')

# Supplies path completions under directories specified by config key.
class PathCompletion < Completion
  class<<self; attr_accessor :config_key; end

  def possible_completions
    Lightning.entries_for_key(self.class.config_key)
  end
end
