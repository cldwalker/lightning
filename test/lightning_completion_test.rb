require File.dirname(__FILE__) + '/test_helper'

class LightningCompletionTest < Test::Unit::TestCase
  context "Completion" do
    
    test "from script matches correctly" do
      Lightning.path_map.stub!(:completions, :return=>%w{at ap blah})
      assert_arrays_equal Lightning::Completion.complete('cd-test a', 'blah'), %w{at ap}
    end
    
    test "for basic case matches correctly" do
      Lightning.path_map.stub!(:completions, :return=>%w{at ap blah})
      @completion = Lightning::Completion.new('cd-test a', 'blah')
      assert_arrays_equal @completion.matches, %w{at ap}
    end
    
    test "with test flag matches correctly" do
      Lightning.path_map.stub!(:completions, :return=>%w{at ap blah})
      @completion = Lightning::Completion.new('cd-test -test a', 'blah')
      assert_arrays_equal @completion.matches, %w{at ap}
    end
  end
end
