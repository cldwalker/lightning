require File.join(File.dirname(__FILE__), 'test_helper')

class Lightning
  class CliTest < Test::Unit::TestCase
    context "Cli Commands:" do
      test "complete defaults to ARGV if no ENV['COMP_LINE']" do
        ARGV.replace(['o-a', 'Col'])
        mock(Cli).complete('o-a', 'o-a Col')
        capture_stdout { Cli.complete_command('o-a') }
      end

      test "complete prints usage for no arguments" do
        capture_stdout { Cli.complete_command(nil) }.should =~ /^Usage/
      end

      test "complete prints error for invalid command" do
        capture_stdout { Cli.complete_command('invalid','invalid') }.should =~ /#Error/
      end
  
      test "translate prints usage for no arguments" do
        capture_stdout { Cli.translate_command([]) }.should =~ /^Usage/
      end

      test "translate prints nothing for command with no arguments" do
        capture_stdout { Cli.translate_command(['one']) }.should == ''
      end

      test "translate prints error for invalid command" do
        capture_stdout { Cli.translate_command(%w{invalid blah}) }.should =~ /#Error/
      end

      test "builder prints error when unable to build" do
        Lightning.config[:shell] = 'blah'
        capture_stdout { Cli.build_command }.should =~ /No.*exists.*blah shell/
        Lightning.config[:shell] = nil
      end
    end
  end
end
