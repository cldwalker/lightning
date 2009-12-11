require File.join(File.dirname(__FILE__), 'test_helper')

class Lightning
  class GeneratorTest < Test::Unit::TestCase
    context "Generator" do
      before(:all) do
        Lightning.instance_eval "@commands = {}" #reset because of mocks
        @source_file =  File.dirname(__FILE__) + '/lightning_completions'
        Cli.generate_command [@source_file]
      end
      after(:all) {  FileUtils.rm_f(@source_file) }
    
      test "generates file in expected location" do
        assert File.exists?(@source_file)
      end

      # depends on test/lightning.yml
      test "generates expected output for a command" do
        expected = <<-EOS.gsub(/^\s{8}/,'')
        #open mac applications
        oa () {
          open -a `${LBIN_PATH}lightning-translate oa $@`
        }
        complete -o default -C "${LBIN_PATH}lightning-complete oa" oa
        EOS
        assert_equal Generator::HEADER + "\n\n"+ expected, File.read(@source_file)
      end
    end
  end
end