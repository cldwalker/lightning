require File.join(File.dirname(__FILE__), 'test_helper')

class Lightning
  class CliTest < Test::Unit::TestCase
    context "Generator" do
      before(:all) do
        @config_file =  File.dirname(__FILE__) + '/lightning_completions'
        Generator.generate_completions @config_file
      end
      after(:all) {  FileUtils.rm_f(@config_file) }
    
      test "generates file in expected location" do
        assert File.exists?(@config_file)
      end

      #this depends on oa 
      test "generates expected output for a command" do
        generated_command = <<-EOS.gsub(/^\s{8}/,'')
        #open mac applications
        oa () {
          if [ -z "$1" ]; then
            echo "No arguments given"
            return
          fi
          FULL_PATH="`${LBIN_PATH}lightning-translate oa $@`"
          if [ $1 == '-test' ]; then
            CMD="open -a '$FULL_PATH'"
            echo $CMD
          else
            open -a "$FULL_PATH"
          fi
        }
        complete -o default -C "${LBIN_PATH}lightning-complete oa" oa
        EOS
        output = File.read(@config_file)
        assert output.include?(generated_command)
      end
    end
  
    context "Shell Commands" do
      test "complete() returns correctly for valid command" do
        stub(Completion).complete { 'blah' }
        assert_equal 'blah', Cli.complete('oa', 'blah')
      end

      test "complete prints error for no command" do
        mock(Cli).exit(1)
        capture_stdout { Cli.complete_command(nil) }.should =~ /#No command given/
      end

      test "complete() reports error for invalid command" do
        assert ! Cli.complete('invalid','invalid').grep(/Error/).empty?
      end
  
      test "translate() returns errorless for valid command" do
        assert Cli.translate('oa', 'blah').grep(/Error/).empty?
      end

      test "translate prints error for no command" do
        mock(Cli).exit(1)
        capture_stdout { Cli.translate_command([]) }.should =~ /#Not enough arg/
      end

      test "translate prints error for one command" do
        mock(Cli).exit(1)
        capture_stdout { Cli.translate_command(['one']) }.should =~ /#Not enough arg/
      end

      test "translate() reports error for invalid command" do
        assert ! Cli.translate('invalid', 'blah').grep(/Error/).empty?
      end
    end
  end
end
