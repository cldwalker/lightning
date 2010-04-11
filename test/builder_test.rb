require File.join(File.dirname(__FILE__), 'test_helper')

context "Builder" do
  def build
    config.source_file = source_file
    Builder.run
  end

  def source_file
    @source_file ||= File.dirname(__FILE__) + '/lightning_completions'
  end

  test "prints error when unable to build" do
    config[:shell] = 'blah'
    capture_stdout { build }.should =~ /No.*exists.*blah shell/
    config[:shell] = nil
  end

  test "with non-default shell builds" do
    config[:shell] = 'zsh'
    mock(Builder).zsh_builder(anything) { '' }
    build
    config[:shell] = nil
  end

  test "warns about existing commands being overridden" do
    mock(Util).shell_command_exists?('bling') { true }
    stub(Util).shell_command_exists?(anything) { false }
    capture_stdout { build }.should =~ /following.*exist.*: bling$/
  end

  context "with default shell" do
    before_all { build }

    test "builds file in expected location" do
      File.exists?(source_file).should == true
    end

    # depends on test/lightning.yml
    test "builds expected output for a command" do
      expected = <<-EOS.gsub(/^\s{6}/,'')
      oa () {
        local IFS=$'\\n'
        local arr=( $(${LBIN_PATH}lightning-translate oa $@) )
        open -a "${arr[@]}"
      }
      complete -o default -C "${LBIN_PATH}lightning-complete oa" oa
      EOS
      File.read(source_file).include?(expected).should == true
    end
  end

  after_all {  FileUtils.rm_f(source_file) }
end
