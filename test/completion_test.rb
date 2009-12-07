require File.join(File.dirname(__FILE__), 'test_helper')

class Lightning::CompletionTest < Test::Unit::TestCase
  context "Completion" do
    before(:each) {
      @key = 'blah'; 
      Lightning.commands[@key].stub!(:completions, :return=>%w{at ap blah})
      Lightning.config[:complete_regex] = true
    }
    test "from script matches" do
      Lightning.config[:complete_regex] = false
      assert_arrays_equal %w{at ap}, Lightning::Completion.complete('cd-test a', @key)
    end
    
    test "for basic case matches" do
      Lightning.config[:complete_regex] = false
      @completion = Lightning::Completion.new('cd-test a', @key)
      assert_arrays_equal %w{at ap}, @completion.matches
    end
    
    test "with test flag matches" do
      Lightning.config[:complete_regex] = false
      @completion = Lightning::Completion.new('cd-test -test a', @key)
      assert_arrays_equal %w{at ap}, @completion.matches
    end
    
    test "with complete_regex on matches" do
      Lightning.config[:complete_regex] = true
      @completion = Lightning::Completion.new('cd-test *', @key)
      assert_arrays_equal %w{at ap blah}, @completion.matches
    end
    
    test "with invalid regex is rescued" do
      Lightning.config[:complete_regex] = true
      @completion = Lightning::Completion.new('cd-test []', @key)
      assert !@completion.matches.grep(/Error/).empty?
    end
  end
  
  test "blob_to_regex converts * to .*" do
    @lc = Lightning::Completion.new('blah', @key)
    assert_equal '.*a.*blah', @lc.blob_to_regex('*a*blah')
  end
  
  test "blob_to_regex doesn't modify .*" do
    @lc = Lightning::Completion.new('blah', @key)
    assert_equal '.*blah.*', @lc.blob_to_regex('.*blah.*')
  end
end
