require File.join(File.dirname(__FILE__), 'test_helper')

class Lightning
  class CommandTest < Test::Unit::TestCase
    def create_command(attributes)
      @cmd = Command.new({'name'=>'blah'}.merge(attributes))
      @cmd.completion_map.map = {'path1'=>'/dir/path1','path2'=>'/dir/path2','path3'=>'/dir/path3'}
    end

    def translate(input, expected)
      Lightning.commands['blah'] = @cmd
      mock(Cli).puts(expected)
      Cli.translate_command ['blah'] + input.split(' ')
    end

    context "Command" do
      before(:all) do
        Lightning.config[:aliases] = {'g2'=>'/dir/g2', 'a2'=>'/dir/g2'}
        create_command('aliases'=>{'a1'=>'/dir/a1', 'a2'=>'/dir/a2', 'path3'=>'/dir/a3'})
        @map = @cmd.completion_map
      end
      after(:all) { Lightning.config[:aliases] = {}}

      test "has correct completions" do
        assert_arrays_equal %w{a1 a2 g2 path1 path2 path3}, @cmd.completions
      end

      test "translates a completion" do
        translate 'path1', @map['path1']
      end

      test "translates multiple completions" do
        translate 'path1 path2', @map['path1'] + ' '+ @map['path2']
      end

      test "translates non-completion to same string" do
        translate 'blah', 'blah'
      end

      test "translates completion anywhere amongst non-completions" do
        translate '-r path1', "-r #{@map['path1']}"
        translate '-r path1 doc/', "-r #{@map['path1']} doc/"
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
        translate '-r path1 path2', '-r /dir/path1/rdoc/index.html /dir/path2/rdoc/index.html'
      end

      test "add_to_command added after whole translation" do
        create_command 'add_to_command'=>'| pbcopy'
        translate '-r path1', '-r /dir/path1| pbcopy'
      end
    end
  end
end