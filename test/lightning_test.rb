require File.dirname(__FILE__) + '/test_helper'

class LightningTest < Test::Unit::TestCase
  context "Generator" do
    before(:all) do
      @config_file =  File.dirname(__FILE__) + '/lightning_completions'
      Lightning.config[:generated_file] = @config_file
      Lightning::Generator.generate_completions
    end
    after(:all) {  FileUtils.rm_f(Lightning.config[:generated_file]) }
    
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
        FULL_PATH="`${LBIN_PATH}lightning-full_path open-oa $@`"
        if [ $1 == '-test' ]; then
          CMD="open -a '$FULL_PATH'"
          echo $CMD
        else
          open -a "$FULL_PATH"
        fi
      }
      complete -o default -C "${LBIN_PATH}lightning-complete open-oa" oa
      EOS
      output = File.read(@config_file)
      assert output.include?(generated_command)
    end
  end
  
  test "creates bolt only once when accessing same bolt multiple times" do
    pending "sometimes fails with rake task" do
    # @map.expects(:create_map).once.returns({})
    called = 0
    # Lightning.reset_bolts
    Lightning::Bolt.stub!(:new) { p "CALLED"; called += 1}
    # @map.stub!(:create_map) {|e| called += 1; {}}
    Lightning.bolts['blah']
    Lightning.bolts['blah']
    assert called == 1
    end
  end
end
