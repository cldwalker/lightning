require File.join(File.dirname(__FILE__), 'test_helper')

class Lightning
  class CliTest < Test::Unit::TestCase
    context "Cli Commands:" do
      test "complete defaults to ARGV if no ENV['COMP_LINE']" do
        ARGV.replace(['o-a', 'Col'])
        mock(Cli).exit(0)
        mock(Cli).complete('o-a', 'o-a Col')
        capture_stdout { Cli.complete_command('o-a') }
      end

      test "complete prints usage for no arguments" do
        mock(Cli).exit(1)
        capture_stdout { Cli.complete_command(nil) }.should =~ /^Usage/
      end

      test "complete prints error for invalid command" do
        mock(Cli).exit(0)
        mock(Cli).puts(["#Error: No paths found for this command."])
        Cli.complete_command('invalid','invalid')
      end
  
      test "translate prints usage for no arguments" do
        mock(Cli).exit(1)
        capture_stdout { Cli.translate_command([]) }.should =~ /^Usage/
      end

      test "translate prints nothing for command with no arguments" do
        mock(Cli).exit(1)
        capture_stdout { Cli.translate_command(['one']) }.should == ''
      end

      test "translate prints error for invalid command" do
        mock(Cli).exit(0)
        capture_stdout { Cli.translate_command(%w{invalid blah}) }.should =~ /#Error/
      end

      test "generator prints error when unable to generate" do
        Lightning.config[:shell] = 'blah'
        capture_stdout { Cli.generate_command }.should =~ /No.*exists.*blah shell/
        Lightning.config[:shell] = nil
      end
    end
  end
end
