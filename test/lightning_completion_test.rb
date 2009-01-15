require File.dirname(__FILE__) + '/test_helper'

class LightningCompletionTest < Test::Unit::TestCase
  context "Completion" do
    
    test "for basic case matches correctly" do
      Lightning.stub!(:completions_for_key, :return=>%w{at ap blah})
      @completion = Lightning::Completion.new('cd-test a', 'blah')
      assert_arrays_equal @completion.matches, %w{at ap}
    end
    
    test "with test flag matches correctly" do
      Lightning.stub!(:completions_for_key, :return=>%w{at ap blah})
      @completion = Lightning::Completion.new('cd-test -test a', 'blah')
      assert_arrays_equal @completion.matches, %w{at ap}
    end
  end
end
