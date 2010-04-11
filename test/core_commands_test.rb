require File.join(File.dirname(__FILE__), 'test_helper')

context "Core commands" do
  test "complete defaults to ARGV if no ENV['COMP_LINE']" do
    mock(Completion).complete('o-a Col', anything)
    capture_stdout { run_command(:complete, ['o-a', 'Col']) }
  end

  test "complete prints usage for no arguments" do
    capture_stdout { run_command(:complete, []) }.should =~ /^Usage/
  end

  test "complete prints error for invalid command" do
    capture_stdout { run_command(:complete, ['invalid','invalid']) }.should =~ /^#Error.*Please/m
  end

  test "translate prints usage for no arguments" do
    capture_stdout { run_command(:translate, [])
      }.should =~ /'lightning translate'.*incorrectly.*Usage:/m
  end

  test "translate prints error for invalid command" do
    capture_stdout { run_command(:translate, %w{invalid blah}) }.should =~ /#Error/
  end

  context "first install" do
    before_all {
      @old_config = config
      Lightning.config = Lightning::Config.new({})
      @old_functions = Lightning.functions
      Lightning.functions = nil

      mock(config).save.times(2)
      mock(Commands).first_install? { true }.times(2)
      stub.instance_of(Generator).call_generator { [] }
      mock(File).open(anything, 'w')
      @stdout = capture_stdout { run_command :install }
    }

    assert "generates default bolts" do
      Generator::DEFAULT_GENERATORS.all? {|e| config[:bolts].key?(e) }
    end

    assert "default bolts are global" do
      Generator::DEFAULT_GENERATORS.all? {|e| config[:bolts][e]['global'] }
    end

    test "builds 8 default functions" do
      expected = %w{cd-gem cd-local_ruby cd-ruby cd-wild echo-gem echo-local_ruby echo-ruby echo-wild}
      Lightning.functions.keys.sort.should == expected
    end

    test "prints correct install message" do
      @stdout.should =~ /^Created.*lightningrc\nCreated.*functions\.sh for bash/m
    end

    after_all { Lightning.config = @old_config; Lightning.functions = @old_functions }
  end
end