require File.join(File.dirname(__FILE__), 'test_helper')

class Lightning
  class BuilderTest < Test::Unit::TestCase
    context "Builder" do
      before(:all) do
        @source_file =  File.dirname(__FILE__) + '/lightning_completions'
        run_command :build, [@source_file]
      end
      after(:all) {  FileUtils.rm_f(@source_file) }
    
      test "builds file in expected location" do
        assert File.exists?(@source_file)
      end

      # depends on test/lightning.yml
      test "builds expected output for a command" do
        expected = <<-EOS.gsub(/^\s{8}/,'')
        #open mac applications
        oa () {
          open -a `${LBIN_PATH}lightning-translate oa $@`
        }
        complete -o default -C "${LBIN_PATH}lightning-complete oa" oa
        EOS
        assert File.read(@source_file).include?(expected)
      end
    end
  end
end