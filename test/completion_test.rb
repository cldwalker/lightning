require File.join(File.dirname(__FILE__), 'test_helper')

class Lightning
  class CompletionTest < Test::Unit::TestCase
  context "Completion" do
    before(:each) {
      stub(Cli).exit(0)
      @command = 'blah';
      mock(cmd = Object.new).completions { %w{at ap blah} }
      Lightning.commands[@command] = cmd
    }
    def tab(input, expected, complete_regex=false)
      Lightning.config[:complete_regex] = complete_regex
      mock(Cli).puts(expected)
      Cli.complete_command @command, input
    end

    test "from script matches" do
      tab 'cd-test a', %w{at ap}
    end
    
    test "for word with a space matches" do
      tab 'cd-test a ', %w{at ap}
    end
    
    test "with test flag matches" do
      tab 'cd-test -test a', %w{at ap}
    end

    context "with a regex" do
      test "matches starting letters" do
        tab 'cd-test a', %w{at ap}, true
      end

      test "and asterisk matches" do
        tab 'cd-test *', %w{at ap blah}, true
      end
    
      test "which is invalid errors gracefully" do
        tab 'cd-test []', ['#Error: Invalid regular expression'], true
      end
    end
  end
  
  test "blob_to_regex converts * to .*" do
    @lc = Completion.new('blah', @key)
    assert_equal '.*a.*blah', @lc.blob_to_regex('*a*blah')
  end
  
  test "blob_to_regex doesn't modify .*" do
    @lc = Completion.new('blah', @key)
    assert_equal '.*blah.*', @lc.blob_to_regex('.*blah.*')
  end
  end
end