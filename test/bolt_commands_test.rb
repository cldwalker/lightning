require File.join(File.dirname(__FILE__), 'test_helper')

context "bolt command" do
  def bolt(*args)
    run_command :bolt, args
  end

  def command_wont_find(bolt)
    mock(Commands).puts "Can't find bolt '#{bolt}'"
  end

  def create_bolt(bolt='abcd')
    config.bolts[bolt] = Lightning::Config.bolt(['/a/b/c/d'])
  end

  test 'list lists bolts' do
    mock(Commands).puts config.bolts.keys.sort
    bolt 'list'
  end

  test 'list lists bolts and aliases with --alias' do
    mock(Commands).print_sorted_hash({"app"=>nil, "wild_dir"=>"w", 'live_glob' => nil})
    bolt 'list', '--alias'
  end

  test 'alias aliases a bolt' do
    create_bolt
    mock(Commands).save_and_say /Aliased.*'abcd'.*'ab'/
    bolt 'alias', 'abcd', 'ab'
    config.bolts['abcd']['alias'].should == 'ab'
  end

  test "alias prints error for nonexistent bolt" do
    command_wont_find 'zzz'
    bolt 'alias', 'zzz', 'z'
  end

  test "create creates a bolt" do
    mock(Commands).save_and_say /Created.*'blah'/
    paths = '/some/path', '/some/path2'
    bolt 'create', 'blah', *paths
    config.bolts['blah'] = Lightning::Config.bolt(paths)
  end

  test 'delete deletes a bolt' do
    mock(Commands).save_and_say /Deleted.*'blah'/
    bolt 'delete', 'blah'
    config.bolts['blah'].should.be.nil
  end

  test 'delete prints error for nonexistent bolt' do
    command_wont_find 'zzz'
    bolt 'delete', 'zzz'
  end

  test "generate generates bolt" do
    mock(Generator).run('ruby19', :once=>'ruby', :test=>nil)
    bolt 'generate', 'ruby19', 'ruby'
  end

  test "generate test generates bolt with --test" do
    mock(Generator).run('ruby19', :once=>'ruby', :test=>true)
    bolt 'generate', 'ruby19', 'ruby', '--test'
  end

  test 'show shows bolt' do
    create_bolt
    mock(Commands).puts(/globs:.*c\/d/m)
    bolt 'show', 'abcd'
  end

  if RUBY_VERSION > '1.9.2'
    test 'show shows bolt given alias' do
      create_bolt
      config.bolts['abcd']['alias'] = 'ab'
      mock(Commands).puts(/globs:.*c\/d.*alias: ab/m)
      bolt 'show', 'ab'
    end
  end

  test 'show prints error for nonexistent bolt' do
    command_wont_find 'zzz'
    bolt 'show', 'zzz'
  end

  test 'global prints error if first argument invalid' do
    mock(Commands).puts(/First argument must be/)
    bolt 'global', 'zero', 'ok'
  end

  context 'global' do
    before_all {create_bolt('foo'); create_bolt('bar') }

    test 'sets bolts on' do
      mock(Commands).save_and_say /Global on.* foo, bar/
      bolt 'global', 'on', 'foo', 'bar'
      config.bolts['foo']['global'].should == true
      config.bolts['bar']['global'].should == true
    end

    test 'on prints error for nonexistent bolt' do
      command_wont_find 'far'
      mock(Commands).save_and_say /Global on.* foo/
      bolt 'global', 'on', 'foo', 'far'
    end

    test 'sets bolts off' do
      mock(Commands).save_and_say /Global off.* foo, bar/
      bolt 'global', 'off', 'foo', 'bar'
      config.bolts['foo']['global'].should == nil
      config.bolts['bar']['global'].should == nil
    end

    test 'off prints error for nonexistent bolt' do
      command_wont_find 'far'
      mock(Commands).save_and_say /Global off.* foo/
      bolt 'global', 'off', 'foo', 'far'
    end
    after_all { config.bolts.delete('bar'); config.bolts.delete('foo') }
  end
end
