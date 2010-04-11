require File.join(File.dirname(__FILE__), 'test_helper')

context "shell_command command" do
  def shell_command(*args)
    run_command :shell_command, args
  end

  test "lists shell commands" do
    mock(Commands).puts config.global_commands.sort
    shell_command('list')
  end

  context "create" do
    test "prints error if command alias already exists" do
      mock(Commands).puts(/Alias/)
      shell_command 'create', 'cd'
    end

    test "creates a shell command" do
      mock(Commands).save_and_say /^Created.*'man'/
      shell_command 'create', 'man'
      config.shell_commands['man'].should == 'man'
    end

    test "creates a shell command with alias" do
      mock(Commands).save_and_say /Created.*'man'/
      shell_command 'create', 'man', 'm'
      config.shell_commands['man'].should == 'm'
    end
  end

  test "delete deletes a shell command" do
    mock(Commands).save_and_say /Deleted.*'man'/
    config.shell_commands['man'].should.not.be.empty
    shell_command 'delete', 'man'
    config.shell_commands['man'].should.be.nil
  end

  test "delete prints error if nonexistent shell command" do
    mock(Commands).puts /Can't.*'doy'/
    shell_command 'delete', 'doy'
  end
end