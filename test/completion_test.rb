require File.join(File.dirname(__FILE__), 'test_helper')

class Lightning
  class CompletionTest < Test::Unit::TestCase
    context "Completion" do
      before(:each) {
        @command = 'blah';
        cmd = Command.new 'name'=>@command, 'bolt'=>Bolt.new('blah')
        stub(cmd).completions { ['at', 'ap', 'blah', 'has space'] }
        Lightning.commands[@command] = cmd
      }

      def tab(input, expected, complete_regex=false)
        Lightning.config[:complete_regex] = complete_regex
        mock(Cli).puts(expected)
        run_command :complete, [@command, 'cd-test '+ input]
      end

      test "from script matches" do
        tab 'a', %w{at ap}
      end
    
      test "ending with space matches everything" do
        tab 'a ', ["at", "ap", "blah", "has\\ space"]
      end
    
      test "has no matches" do
        tab 'zaza', []
      end

      test "has no matches for a local directory" do
        tab 'bling/ok', []
      end

      test "with multiple words matches last word" do
        tab '-r b', ['blah']
      end

      test "with multiple words matches quoted last word" do
        tab '-r "b"', ['blah']
      end

      test "with multiple words matches shell escaped last word" do
        tab 'lib has\\ ', ['has\\ space']
      end

      test "in nonexistent subdirectory errors properly" do
        tab 'at/', ["#Error: Nonexistent directory"]
      end

      test "in bolt subdirectory matches" do
        mock(Dir).entries('at') { ['..', '.', 'f1']}
        tab 'at/', ['at/f1']
      end

      test "in nested bolt subdirectory matches" do
        mock(Dir).entries('at/the') { ['f1']}
        tab 'at/the/', ['at/the/f1']
      end

      test "for directory in bolt subdirectory matches and appends / " do
        stub(File).directory? { true }
        mock(Dir).entries('at/the') { %w{ab lib}}
        tab 'at/the/l', ['at/the/lib/']
      end

      test "for file in bolt subdirectory matches" do
        mock(Dir).entries('at/the') { %w{ab ge fe fi fo}}
        tab 'at/the/f', ['at/the/fe', 'at/the/fi', 'at/the/fo']
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
      @lc = Completion.new('blah', nil)
      assert_equal '.*a.*blah', @lc.blob_to_regex('*a*blah')
    end
  
    test "blob_to_regex doesn't modify .*" do
      @lc = Completion.new('blah', nil)
      assert_equal '.*blah.*', @lc.blob_to_regex('.*blah.*')
    end
  end
end