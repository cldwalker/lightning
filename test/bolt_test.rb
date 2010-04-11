require File.join(File.dirname(__FILE__), 'test_helper')

# depends on test/lightning.yml
context "Bolt generates functions from" do
  test "non-global bolt" do
    config.bolts['wild_dir']['functions'] = ['mv']
    Lightning.functions['mv-w'].is_a?(Function).should == true
    Lightning.functions.delete('mv-w')
    config.bolts['wild_dir'].delete('functions')
  end

  assert "shell command" do
    Lightning.functions['less-app'].is_a?(Function)
  end

  assert "command hash" do
    Lightning.functions['oa'].is_a?(Function)
  end

  assert "global shell command" do
    Lightning.functions['grep-app'].is_a?(Function)
  end

  assert "aliased global shell command in config" do
    Lightning.functions['v-app'].is_a?(Function)
  end

  assert "global shell command which has a local config" do
    Lightning.functions['c'].is_a?(Function)
  end
end
