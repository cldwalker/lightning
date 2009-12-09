require File.join(File.dirname(__FILE__), 'test_helper')

class Lightning
  class CommandTest < Test::Unit::TestCase
    context "Command" do
      before(:each) do
        @cmd = Command.new('name'=>'blah', 'paths'=>[])
        @cmd.completion_map.map = {'path1'=>'/dir/path1','path2'=>'/dir/path2'}
      end

      def translate(input, expected)
        Lightning.commands['blah'] = @cmd
        mock(Cli).exit(0)
        mock(Cli).puts(expected)
        Cli.translate_command ['blah'] + input.split(' ')
      end

      test "translates completion" do
        translate 'path1', @cmd.completion_map['path1']
      end

      test "translates completion with test flag" do
        translate '-test path1', @cmd.completion_map['path1']
      end

      test "translates no completion to empty string" do
        translate 'blah', ''
      end
    end
  
    test "Command's completion_map sets up alias map with options" do
      old_config = Lightning.config
      Lightning.config = Config.new({:aliases=>{'path1'=>'/dir1/path1'}, :commands=>[{'name'=>'blah'}], :paths=>{}})
      @cmd = Command.new('name'=>'blah', 'paths'=>[])
      assert_equal({'path1'=>'/dir1/path1'}, @cmd.completion_map.alias_map)
      Lightning.config = Config.new(old_config)
    end
  end
end