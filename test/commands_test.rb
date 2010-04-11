require File.join(File.dirname(__FILE__), 'test_helper')

context "Commands:" do
  test "run_command handles unexpected error" do
    mock($stderr).puts(/^Error: Unexpected/)
    mock(Commands).complete(anything) { raise "Unexpected" }
    run_command :complete
  end

  test "generic command prints usage with -h" do
    capture_stdout { run_command :install, ['-h'] }.should =~ /^Usage/
  end

  test "generic command prints error if invalid subcommand" do
    mock(Commands).puts /Invalid.*'blah'/, anything
    run_command 'function', ['blah']
  end

  test "generic command can take abbreviated subcommand" do
    mock(Commands).list_function(anything)
    run_command 'function', ['l']
  end

  context "run" do
    test "with no command prints usage" do
      mock(Commands).print_help
      Commands.run []
    end

    test "with aliased command executes correct command" do
      mock(Commands).run_command('bolt', [])
      Commands.run ['b']
    end

    test "with -h prints usage" do
      mock(Commands).print_help
      Commands.run ['-h']
    end

    test "with invalid command prints messaged and usage" do
      mock(Commands).print_help
      capture_stdout { Commands.run ['blah'] }.should =~ /Command 'blah'/
    end

    test "passes -h as command argument" do
      mock(Commands).print_command_help.never
      mock(Commands).complete(['blah', '-h'])
      Commands.run(['complete', 'blah', '-h'])
    end
  end
end