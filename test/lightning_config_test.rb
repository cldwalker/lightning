require File.join(File.dirname(__FILE__), 'test_helper')

class LightningConfigTest < Test::Unit::TestCase
  context "A config" do
    before(:all) {
      @config = Lightning.read_config_file(File.dirname(__FILE__) + '/lightning.yml')
    }
    
    should "be a hash" do
      assert @config.is_a?(Hash)
    end
    
    should "have keys that are symbols" do
      assert @config.keys.all? {|e| e.is_a?(Symbol)}
    end
    
    should "have read supported keys" do
      supported_keys = [:generated_file, :commands, :ignore_paths, :paths, :shell, :complete_regex]
      assert_arrays_equal supported_keys, @config.keys 
    end
    
    should "have a generated_file key which is a string" do
      assert @config[:generated_file].is_a?(String)
    end
    
    should "have a commands key which is an array" do
      assert @config[:commands].is_a?(Array)
    end
    
    should "have a command with valid keys" do
      assert @config[:commands][0].slice('name', 'map_to', 'description').values.all? {|e| e.is_a?(String)}
      assert @config[:commands][0]['paths'].is_a?(Array)
    end
    
    should "have a paths key which is a hash" do
      assert @config[:paths].is_a?(Hash)
    end
    
    should "have an ignore_paths key which is an array" do
      assert @config[:ignore_paths].is_a?(Array)
    end
  end
  
  context ":configure_commands_and_paths" do
    test "generates bolt key if none exists" do
      config = {:commands=>[{'name'=>'c1', 'map_to'=>'s1'}]}
      assert ! Lightning.configure_commands_and_paths(config)[:commands][0]['bolt_key'].nil?
    end
    
    test "adds generated bolt key to config.paths if it didn't exist" do
      config = {:commands=>[{'name'=>'c1', 'map_to'=>'s1', 'paths'=>['*']}]}
      new_config = Lightning.configure_commands_and_paths(config)
      bolt_key = new_config[:commands][0]['bolt_key']
      assert new_config[:paths].has_key?(bolt_key)
    end
    
    test "adds reference to bolt key if command.paths is a string" do
      config = {:commands=>[{'name'=>'c1', 'map_to'=>'s1', 'paths'=>'blah'}]}
      assert_equal 'blah', Lightning.configure_commands_and_paths(config)[:commands][0]['bolt_key']
    end
  end
end
