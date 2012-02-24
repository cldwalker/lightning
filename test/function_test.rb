require File.join(File.dirname(__FILE__), 'test_helper')

context "Function" do
  # bolt, path and aliases depend on test/lightning.yml
  def create_function(attributes={})
    Function.new({'name'=>'blah', 'bolt'=>Bolt.new('app'), 'desc'=>'blah'}.merge(attributes))
  end

  context "basic function" do
    def translate(*args); super(@fn, *args); end
    def map; @fn.completion_map; end

    before do
      @fn = create_function
      @fn.completion_map.map = {'path1'=>'/dir/path1','path2'=>'/dir/path2',
        'path3'=>'/dir/path3', 'file 1'=>'/dir/file 1'}
    end

    test "has correct completions" do
      assert_arrays_equal %w{a1 a2}+['file 1']+%w{path1 path2 path3}, @fn.completions
    end

    test "has bolt's globs" do
      @fn.globs.should.not.be.empty?
      @fn.globs.should == @fn.bolt.globs
    end

    test "has bolt's aliases" do
      @fn.aliases.should.not.be.empty?
      @fn.aliases.should == @fn.bolt.aliases
    end

    test "can have a desc" do
      @fn.desc.should.not.be.empty?
    end

    test "translates a completion" do
      translate 'path1', map['path1']
    end

    test "translates multiple completions separately" do
      translate 'path1 path2', map['path1'], map['path2']
    end

    if RUBY_VERSION > '1.9.2'
      test "translates instant multiple completions (..)" do
        translate 'path.. blah a1', map['path1'], map['path2'], map['path3'], 'blah', map['a1']
      end
    end

    test "translates instant multiple completions containing spaces" do
      translate 'file..', map['file 1']
    end

    test "translates non-completion to same string" do
      translate 'blah', 'blah'
    end

    test "translates completion anywhere amongst non-completions" do
      translate '-r path1', "-r", "#{map['path1']}"
      translate '-r path1 doc/', "-r", "#{map['path1']}", "doc/"
    end

    test "translates completion embedded in subdirectory completion" do
      translate '-r path1/sub/dir', "-r", "#{map['path1']}/sub/dir"
    end

    test "translates completion with a superdirectory" do
      mock(File).expand_path("#{map['path1']}/../file1") { '/dir/file1' }
      translate 'path1/../file1', '/dir/file1'
    end

    test "translates completion over alias" do
      translate 'path3', '/dir/path3'
    end

    test "translates alias" do
      translate 'a1', map['a1']
    end

    after_all { config[:aliases] = {}}
  end

  context "function with global variables" do
    before { @fn = create_function; ENV['MY_HOME'] = '/my/home' }
    after { ENV.delete 'MY_HOME' }

    test "has globs that expand shell variables" do
      orig = @fn.bolt.globs.dup
      @fn.bolt.globs << '$MY_HOME/*.rc'
      @fn.globs.should == orig << '/my/home/*.rc'
    end

    test "has aliases that expand shell variables" do
      orig = @fn.bolt.aliases.dup
      @fn.bolt.aliases['f'] = '$MY_HOME/file'
      @fn.aliases.should == orig.merge('f' => '/my/home/file')
    end
  end

  context "with" do
    test "live globs" do
      live_globs = %w{one two three}
      Lightning::Generators.send(:define_method, :live_glob) { live_globs * 2 }
      @fn = create_function 'bolt' => Bolt.new('live_glob')
      @fn.globs.should == live_globs * 2
    end
    test "post_path added after each translation" do
      @fn = create_function 'post_path'=>'/rdoc/index.html'
      @fn.completion_map.map = {'path1'=>'/dir/path1','path2'=>'/dir/path2',
        'path3'=>'/dir/path3', 'file 1'=>'/dir/file 1'}
      translate @fn, '-r path1 path2', "-r", "/dir/path1/rdoc/index.html", "/dir/path2/rdoc/index.html"
    end
  end
end
