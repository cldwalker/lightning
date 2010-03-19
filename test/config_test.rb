require File.join(File.dirname(__FILE__), 'test_helper')

context "A config" do
  before_all {
    @config = Lightning::Config.new
  }

  assert "has keys that are symbols" do
    @config.keys.all? {|e| e.is_a?(Symbol)}
  end
  
  assert "has read supported keys" do
    supported_keys = [:source_file, :ignore_paths, :bolts, :complete_regex]
    supported_keys.all? {|e| @config.key?(e) }
  end
  
  assert "has a source_file key which is a string" do
    @config[:source_file].is_a?(String)
  end
  
  assert "has a bolts key which is a hash" do
    @config[:bolts].is_a?(Hash)
  end
  
  assert "has an ignore_paths key which is an array" do
    @config[:ignore_paths].is_a?(Array)
  end
end
