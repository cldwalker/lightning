require File.join(File.dirname(__FILE__), 'test_helper')

# depends on test/lightning.yml
context "Bolt generates correct command from" do
  before_all { Lightning.setup }

  assert "shell command" do
    Lightning.commands['less-app'].is_a?(Lightning::Command)
  end

  assert "command hash" do
    Lightning.commands['oa'].is_a?(Lightning::Command)
  end

  assert "global shell command" do
    Lightning.commands['grep-app'].is_a?(Lightning::Command)
  end

  assert "aliased global shell command in config" do
    Lightning.commands['v-app'].is_a?(Lightning::Command)
  end

  assert "global shell command which has a local config" do
    Lightning.commands['c'].is_a?(Lightning::Command)
  end
end
