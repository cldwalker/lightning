require File.join(File.dirname(__FILE__), 'test_helper')

class Lightning
  class CliTest < Test::Unit::TestCase
    context "Cli Commands:" do
      test "complete defaults to ARGV if no ENV['COMP_LINE']" do
        mock(Cli).complete('o-a', 'o-a Col')
        capture_stdout { run_command(:complete, ['o-a', 'Col']) }
      end

      test "complete prints usage for no arguments" do
        capture_stdout { run_command(:complete) }.should =~ /^Usage/
      end

      test "complete prints error for invalid command" do
        capture_stdout { run_command(:complete, ['invalid','invalid']) }.should =~ /#Error/
      end
  
      test "translate prints usage for no arguments" do
        capture_stdout { run_command(:translate, []) }.should =~ /^Usage/
      end

      test "translate prints nothing for command with no arguments" do
        capture_stdout { run_command(:translate, ['one']) }.should == ''
      end

      test "translate prints error for invalid command" do
        capture_stdout { run_command(:translate, %w{invalid blah}) }.should =~ /#Error/
      end

      test "builder prints error when unable to build" do
        Lightning.config[:shell] = 'blah'
        capture_stdout { run_command(:build) }.should =~ /No.*exists.*blah shell/
        Lightning.config[:shell] = nil
      end

      test "builder prints usage with -h" do
        capture_stdout { run_command :build, '-h' }.should =~ /^Usage/
      end

      test "generator prints usage with -h" do
        capture_stdout { run_command :generate, '-h' }.should =~ /^Usage/
      end
    end
  end
end
