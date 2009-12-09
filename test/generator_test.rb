require File.join(File.dirname(__FILE__), 'test_helper')

class Lightning
  class GeneratorTest < Test::Unit::TestCase
    context "Generator" do
      before(:all) do
        Lightning.instance_eval "@commands = {}" #reset because of mocks
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
            open -a $FULL_PATH
          fi
        }
        complete -o default -C "${LBIN_PATH}lightning-complete oa" oa
        EOS
        output = File.read(@config_file)
        assert output.include?(generated_command)
      end
    end
  end
end