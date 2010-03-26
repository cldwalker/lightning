require File.join(File.dirname(__FILE__), 'test_helper')

context "Completion" do
  before {
    @command = 'blah';
    cmd = Function.new 'name'=>@command, 'bolt'=>Bolt.new('blah')
    stub(cmd).completions { ['at', 'ap', 'blah.rb', 'has space'] }
    Lightning.functions[@command] = cmd
  }

  def tab(input, expected, complete_regex=false)
    Lightning.config[:complete_regex] = complete_regex
    mock(Commands).puts(expected)
    run_command :complete, [@command, 'cd-test '+ input]
  end

  test "from script matches" do
    tab 'a', %w{at ap}
  end

  test "ending with space matches everything" do
    tab 'a ', ["at", "ap", "blah.rb", "has\\ space"]
  end

  test "has no matches" do
    tab 'zaza', []
  end

  test "has no matches for a local directory" do
    tab 'bling/ok', []
  end

  test "with multiple words matches last word" do
    tab '-r b', ['blah.rb']
  end

  test "with multiple words matches quoted last word" do
    tab '-r "b"', ['blah.rb']
  end

  test "with multiple words matches shell escaped last word" do
    tab 'lib has\\ ', ['has\\ space']
  end

  test "in nonexistent subdirectory errors properly" do
    tab 'at/', Completion.error_array("Nonexistent directory.")
  end

  test "in bolt subdirectory matches" do
    mock(Dir).entries('at') { ['..', '.', 'f1']}
    tab 'at/', ['at/f1']
  end

  test "in nested bolt subdirectory matches" do
    mock(Dir).entries('at/the') { ['f1']}
    tab 'at/the/', ['at/the/f1']
  end

  test "for directory in bolt subdirectory matches and appends / " do
    stub(File).directory? { true }
    mock(Dir).entries('at/the') { %w{ab lib}}
    tab 'at/the/l', ['at/the/lib/']
  end

  test "for file in bolt subdirectory matches" do
    mock(Dir).entries('at/the') { %w{ab ge fe fi fo}}
    tab 'at/the/f', ['at/the/fe', 'at/the/fi', 'at/the/fo']
  end

  test "in bolt file's superdirectory matches" do
    mock(File).expand_path('blah.rb/..') { '/dir' }
    mock(Dir).entries('/dir') { ['f1', 'f2'] }
    tab 'blah.rb/../', ['blah.rb/../f1', 'blah.rb/../f2']
  end

  test "in bolt file's superdirectory's subdirectory matches" do
    mock(File).expand_path('blah.rb/../sub') { '/dir/sub' }
    mock(Dir).entries('/dir/sub') { ['f1', 'f2'] }
    tab 'blah.rb/../sub/', ['blah.rb/../sub/f1', 'blah.rb/../sub/f2']
  end

  context "with a regex" do
    test "matches starting letters" do
      tab 'a', %w{at ap}, true
    end

    test "and asterisk matches" do
      tab '[ab]*', %w{at ap blah.rb}, true
    end

    test "with space matches" do
      tab 'has', ['has\\ space']
    end

    test "with typed space matches" do
      tab 'has\\ ', ['has\\ space']
    end

    test "which is invalid errors gracefully" do
      tab '[]', Completion.error_array('Invalid regular expression.'), true
    end
  end
end

context "Completion misc" do
  test "blob_to_regex converts * to .*" do
    @lc = Completion.new('blah', nil)
    @lc.blob_to_regex('*a*blah').should == '.*a.*blah'
  end

  test "blob_to_regex doesn't modify .*" do
    @lc = Completion.new('blah', nil)
    @lc.blob_to_regex('.*blah.*').should == '.*blah.*'
  end

  test "Completion error array must be more than one element to display and not complete error" do
    Completion.error_array("testing").size.should > 1
  end
end
