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

      test "complete prints error for no command" do
        mock(Cli).exit(1)
        capture_stdout { Cli.complete_command(nil) }.should =~ /#No command given/
      end

      test "complete prints error for invalid command" do
        mock(Cli).exit(0)
        mock(Cli).puts(["#Error: No paths found for this command."])
        Cli.complete_command('invalid','invalid')
      end
  
      test "translate prints error for no command" do
        mock(Cli).exit(1)
        capture_stdout { Cli.translate_command([]) }.should =~ /#Not enough arg/
      end

      test "translate prints error for one command" do
        mock(Cli).exit(1)
        capture_stdout { Cli.translate_command(['one']) }.should =~ /#Not enough arg/
      end

      test "translate prints error for invalid command" do
        mock(Cli).exit(0)
        capture_stdout { Cli.translate_command(%w{invalid blah}) }.should =~ /#Error/
      end
    end
  end
end
