require File.join(File.dirname(__FILE__), 'test_helper')

class LightningCompletionTest < Test::Unit::TestCase
  context "Completion" do
    before(:each) {
      @key = 'blah'; 
      Lightning.bolts[@key].stub!(:completions, :return=>%w{at ap blah})
    }
    test "from script matches correctly" do
      assert_arrays_equal Lightning::Completion.complete('cd-test a', @key), %w{at ap}
    end
    
    test "for basic case matches correctly" do
      @completion = Lightning::Completion.new('cd-test a', @key)
      assert_arrays_equal @completion.matches, %w{at ap}
    end
    
    test "with test flag matches correctly" do
      @completion = Lightning::Completion.new('cd-test -test a', @key)
      assert_arrays_equal @completion.matches, %w{at ap}
    end
  end
end
