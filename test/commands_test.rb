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

  def bolt_expects_subcommand_args(bolt, expected)
    Commands.instance_variable_set "@command", bolt
    actual = Commands.send(:subcommand_required_args)
    expected.all? {|k,v| actual[k] == v }.should == true
  end

  test "has correct number of subcommands for bolt" do
    bolt_expects_subcommand_args 'function', {"delete"=>1, "create"=>2}
  end

  test "has correct number of subcommands for shell_command" do
    bolt_expects_subcommand_args 'shell_command', {"delete"=>1, "create"=>1}
  end

  test "has correct number of subcommands for bolt" do
    bolt_expects_subcommand_args 'bolt', {"alias"=>2, 'create'=>2, 'delete'=>1,
      'generate'=>1, 'global'=>2, 'show'=>1}
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

    test "with silent command" do
      capture_stdout { Commands.run ['source_file'] }.should =~ /lightning_completions/
    end

    test "with invalid command prints messaged and usage" do
      mock(Commands).print_help
      capture_stdout { Commands.run ['to_s'] }.should =~ /Command 'to_s'/
    end

    test "passes -h as command argument" do
      mock(Commands).print_command_help.never
      mock(Commands).complete(['blah', '-h'])
      Commands.run(['complete', 'blah', '-h'])
    end
  end
end
