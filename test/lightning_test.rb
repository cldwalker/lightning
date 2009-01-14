require File.dirname(__FILE__) + '/test_helper'

class LightningTest < Test::Unit::TestCase
  context "Generator" do
    before(:all) do
      Lightning.config[:generated_file] = File.dirname(__FILE__) + '/lightning_completions'
      Lightning::Generator.generate_completions
    end
    after(:all) {  FileUtils.rm_f(Lightning.config[:generated_file]) }
    
    test "generates expected file" do
      File.exists?(Lightning.config[:generated_file])
    end
    
    test "generates poop" do
    end
  end
end