require File.join(File.dirname(__FILE__), 'test_helper')

context "function command" do
  def function(*args)
    run_command :function, args
  end

  test "lists functions" do
    mock(Commands).puts Lightning.functions.keys.sort
    function('list')
  end

  test "lists functions with --bolt" do
    mock(Commands).puts Lightning.functions.keys.sort
    function('list', '--bolt=app')
  end

  test "lists functions with --command" do
    mock(Commands).puts ['less-app']
    function('list', '--command=less')
  end

  context "create:" do
    test "creates a function" do
      mock(Commands).save_and_say("Created function 'grep-app'")
      function 'create', 'grep', 'app'
      Lightning.config.bolts['app']['functions'][-1].should == 'grep'
    end

    test "creates a function with bolt alias" do
      mock(Commands).save_and_say("Created function 'grep-w'")
      function 'create', 'grep', 'w'
      Lightning.config.bolts['wild_dir']['functions'][-1].should == 'grep'
    end

    test "creates a function with a global command that has an alias" do
      mock(Commands).save_and_say("Created function 'v-app'")
      function 'create', 'vim', 'app'
      Lightning.config.bolts['app']['functions'][-1].should == 'vim'
    end

    test "creates a function with explicit function name" do
      mock(Commands).save_and_say("Created function 'eap'")
      function 'create', 'emacs', 'app', 'eap'
      Lightning.config.bolts['app']['functions'][-1].should == {"name"=>"eap", "shell_command"=>"emacs"}
    end

    test "fails to generate a bolt and doesn't create a function" do
      mock(Generator).run('bin', :once=>'bin') { false }
      mock(Commands).create_function(anything, anything, anything).never
      function 'create', 'less', 'bin'
    end

    test "generates a bolt and creates a function" do
      mock(Generator).run('bin', :once=>'bin') { true }
      mock(Commands).create_function(anything, anything, anything)
      function 'create', 'less', 'bin'
    end

    test "prints error if trying to create a function with an existing name" do
      mock(Commands).puts(/'less-app'.*exists/)
      function 'create', 'less', 'app'
    end
  end

  # deletes functions created in create context
  context "delete:" do
    test "deletes function" do
      previous_size = Lightning.config.bolts['app']['functions'].size
      mock(Commands).save_and_say("Deleted function 'v-app'")
      function 'delete', 'v-app'
      Lightning.config.bolts['app']['functions'].size.should == previous_size - 1
    end

    # test "deletes function with explicit name" do
    #   previous_size = Lightning.config.bolts['app']['functions'].size
    #   mock(Commands).save_and_say("Deleted function 'eap'")
    #   function 'delete', 'eap'
    #   Lightning.config.bolts['app']['functions'].size.should == previous_size - 1
    # end

    test "prints error message for nonexistant function" do
      mock(Commands).puts /Can't.*'zzz'/
      function 'delete', 'zzz'
    end
  end
end