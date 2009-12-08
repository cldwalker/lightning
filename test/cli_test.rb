require File.join(File.dirname(__FILE__), 'test_helper')

class Lightning::CliTest < Test::Unit::TestCase
  context "Generator" do
    before(:all) do
      @config_file =  File.dirname(__FILE__) + '/lightning_completions'
      Lightning::Generator.generate_completions @config_file
    end
    after(:all) {  FileUtils.rm_f(@config_file) }
    
    test "generates file in expected location" do
      assert File.exists?(@config_file)
    end

    #this depends on oa 
    test "generates expected output for a command" do
      generated_command = <<-EOS.gsub(/^\s{6}/,'')
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
    # test "complete() returns correctly for valid command" do
    #   Lightning::Completion.stub!(:complete, :return=>'blah')
    #   assert_equal 'blah', Lightning::Cli.complete('oa', 'blah')
    # end
  
    test "complete() reports error for invalid command" do
      assert ! Lightning::Cli.complete('invalid','invalid').grep(/Error/).empty?
    end
  
    test "translate() returns errorless for valid command" do
      assert Lightning::Cli.translate('oa', 'blah').grep(/Error/).empty?
    end
    
    test "translate() reports error for invalid command" do
      assert ! Lightning::Cli.translate('invalid', 'blah').grep(/Error/).empty?
    end
  end
end
