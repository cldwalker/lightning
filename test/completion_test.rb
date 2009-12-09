require File.join(File.dirname(__FILE__), 'test_helper')

class Lightning
  class CompletionTest < Test::Unit::TestCase
    context "Completion" do
      before(:each) {
        stub(Cli).exit(0)
        @command = 'blah';
        mock(cmd = Object.new).completions { ['at', 'ap', 'blah', 'has space'] }
        Lightning.commands[@command] = cmd
      }

      def tab(input, expected, complete_regex=false)
        Lightning.config[:complete_regex] = complete_regex
        mock(Cli).puts(expected)
        Cli.complete_command @command, 'cd-test '+ input
      end

      test "from script matches" do
        tab 'a', %w{at ap}
      end
    
      test "ending with space matches everything" do
        tab 'a ', ["at", "ap", "blah", "has\\ space"]
      end
    
      test "with test flag matches" do
        tab '-test a', %w{at ap}
      end

      context "with a regex" do
        test "matches starting letters" do
          tab 'a', %w{at ap}, true
        end

        test "and asterisk matches" do
          tab '[ab]*', %w{at ap blah}, true
        end

        test "with space matches" do
          tab 'has', ['has\\ space']
        end

        test "with typed space matches" do
          tab 'has\\ ', ['has\\ space']
        end

        test "which is invalid errors gracefully" do
          tab '[]', ['#Error: Invalid regular expression'], true
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