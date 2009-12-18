require File.join(File.dirname(__FILE__), 'test_helper')

class Lightning
  class CommandTest < Test::Unit::TestCase
    def create_command(attributes={})
      # bolt, path and aliases depend on test/lightning.yml
      @cmd = Command.new({'name'=>'blah', 'bolt'=>Bolt.new('app')}.merge(attributes))
      @cmd.completion_map.map = {'path1'=>'/dir/path1','path2'=>'/dir/path2',
        'path3'=>'/dir/path3', 'file 1'=>'/dir/file 1'}
    end

    def translate(input, *expected)
      Lightning.commands['blah'] = @cmd
      mock(Cli).puts(expected.join("\n"))
      run_command :translate, ['blah'] + input.split(' ')
    end

    context "Command" do
      before(:all) do
        Lightning.config[:aliases] = {'g2'=>'/dir/g2', 'a2'=>'/dir/g2'}
        create_command
        @map = @cmd.completion_map
      end
      after(:all) { Lightning.config[:aliases] = {}}

      test "has correct completions" do
        assert_arrays_equal %w{a1 a2}+['file 1']+%w{g2 path1 path2 path3}, @cmd.completions
      end

      test "has bolt's paths" do
        assert !@cmd.paths.empty?
        @cmd.paths.should == @cmd.bolt.paths
      end

      test "has bolt's aliases" do
        assert !@cmd.aliases.empty?
        @cmd.aliases.should == @cmd.bolt.aliases
      end

      test "has bolt's desc" do
        assert !@cmd.desc.empty?
        @cmd.desc.should == @cmd.bolt.desc
      end

      test "translates a completion" do
        translate 'path1', @map['path1']
      end

      test "translates multiple completions separately" do
        translate 'path1 path2', @map['path1'], @map['path2']
      end

      test "translates instant multiple completions (..)" do
        translate 'path.. blah a1', @map['path1'], @map['path2'], @map['path3'], 'blah', @map['a1']
      end

      test "translates instant multiple completions containing spaces" do
        translate 'file..', @map['file 1']
      end

      test "translates non-completion to same string" do
        translate 'blah', 'blah'
      end

      test "translates completion anywhere amongst non-completions" do
        translate '-r path1', "-r", "#{@map['path1']}"
        translate '-r path1 doc/', "-r", "#{@map['path1']}", "doc/"
      end

      test "translates completion embedded in subdirectory completion" do
        translate '-r path1/sub/dir', "-r", "#{@map['path1']}/sub/dir"
      end

      test "translates completion over alias" do
        translate 'path3', '/dir/path3'
      end

      test "translates alias over global alias" do
        translate 'a2', '/dir/a2'
      end

      test "translates alias" do
        translate 'a1', @map['a1']
      end

      test "translates global alias" do
        translate 'g2', @map['g2']
      end
    end

    context "command attributes:" do
      test "post_path added after each translation" do
        create_command 'post_path'=>'/rdoc/index.html'
        translate '-r path1 path2', "-r", "/dir/path1/rdoc/index.html", "/dir/path2/rdoc/index.html"
      end
    end
  end
end