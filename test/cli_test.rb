require File.join(File.dirname(__FILE__), 'test_helper')

context "Commands Commands:" do
  # this test seems to run much longer than expected i.e. 0.02
  # rr and raising?
  test "run_command handles unexpected error" do
    mock($stderr).puts(/^Error: Unexpected/)
    mock(Commands).complete_command(anything) { raise "Unexpected" }
    run_command :complete
  end

  test "complete defaults to ARGV if no ENV['COMP_LINE']" do
    mock(Commands).complete('o-a', 'o-a Col')
    capture_stdout { run_command(:complete, ['o-a', 'Col']) }
  end

  test "complete prints usage for no arguments" do
    capture_stdout { run_command(:complete, []) }.should =~ /^Usage/
  end

  test "complete prints error for invalid command" do
    capture_stdout { run_command(:complete, ['invalid','invalid']) }.should =~ /^#Error.*Please/m
  end

  test "translate prints usage for no arguments" do
    capture_stdout { run_command(:translate, []) }.should =~ /^Usage/
  end

  test "translate prints error for invalid command" do
    capture_stdout { run_command(:translate, %w{invalid blah}) }.should =~ /#Error/
  end

  test "install prints usage with -h" do
    capture_stdout { run_command :install, ['-h'] }.should =~ /^Usage/
  end

  test "run with no command prints usage" do
    mock(Commands).print_help
    Commands.run []
  end

  test "run with aliased command executes correct command" do
    mock(Commands).run_command('bolt', [])
    Commands.run ['b']
  end

  test "run with -h prints usage" do
    mock(Commands).print_help
    Commands.run ['-h']
  end

  test "run with invalid command prints messaged and usage" do
    mock(Commands).print_help
    capture_stdout { Commands.run ['blah'] }.should =~ /Command 'blah'/
  end

  test "command should be able to take -h as argument" do
    mock(Commands).print_command_help.never
    mock(Commands).complete_command(['blah', '-h'])
    Commands.run(['complete', 'blah', '-h'])
  end
end