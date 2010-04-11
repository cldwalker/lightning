require File.join(File.dirname(__FILE__), 'test_helper')

context "function command" do
  def function(*args)
    run_command :function, args
  end

  def command_should_print(action, fn)
    mock(Commands).save_and_say("#{action} function '#{fn}'")
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

  test "prints error if invalid subcommand" do
    mock(Commands).puts /Invalid.*'blah'/, anything
    function('blah')
  end

  test "can take abbreviated subcommand" do
    mock(Commands).list_function(anything)
    function('l')
  end

  context "create:" do
    test "creates a function" do
      command_should_print 'Created', 'cp-app'
      function 'create', 'cp', 'app'
      Lightning.config.bolts['app']['functions'][-1].should == {'name'=>'cp-app', 'shell_command'=>'cp'}
    end

    test "creates a function with an aliased bolt" do
      command_should_print 'Created', 'grep-w'
      function 'create', 'grep', 'w'
      Lightning.config.bolts['wild_dir']['functions'][-1].should == 'grep'
    end

    test "creates a function with an aliased global command" do
      command_should_print 'Created', 'v-w'
      function 'create', 'vim', 'wild_dir'
      Lightning.config.bolts['wild_dir']['functions'][-1].should == 'vim'
    end

    test "creates a function similar to a global function" do
      command_should_print 'Created', 'vapp'
      function 'create', 'vim', 'app', 'vapp'
      Lightning.config.bolts['app']['functions'][-1].should == {"name"=>"vapp", "shell_command"=>"vim"}
    end

    test "creates a function with explicit function name" do
      command_should_print 'Created', 'eap'
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
    # reloads bolts/functions
    before_all { Lightning.functions = nil; Lightning.bolts.delete_if { true } }

    def function_count(bolt)
      Lightning.config.bolts[bolt]['functions'].size
    end

    context "deletes" do
      before { @previous_count = function_count('app') }
      after { function_count('app').should == @previous_count - 1 }

      test "a function" do
        command_should_print 'Deleted', 'cp-app'
        function 'delete', 'cp-app'
      end

      test "a function with an aliased global command" do
        command_should_print 'Deleted', 'v-app'
        function 'delete', 'v-app'
      end

      test "a function with explicit name" do
        command_should_print 'Deleted', 'eap'
        function 'delete', 'eap'
      end
    end

    test "deletes a function with an aliased bolt" do
      @previous_count = function_count('wild_dir')
      command_should_print 'Deleted', 'grep-w'
      function 'delete', 'grep-w'
      function_count('wild_dir').should == @previous_count - 1
    end

    test "prints error if global function" do
      mock(Commands).puts /Can't.*'grep-app'/, anything
      function 'delete', 'grep-app'
    end

    test "prints error for nonexistent function" do
      mock(Commands).puts /Can't.*'zzz'/
      function 'delete', 'zzz'
    end
  end
end