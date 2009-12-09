require File.join(File.dirname(__FILE__), 'test_helper')

class Lightning
  class CommandTest < Test::Unit::TestCase
    context "Command" do
      before(:all) do
        Lightning.config[:aliases] = {'a2'=>'/dir/a2'}
        @cmd = Command.new('name'=>'blah', 'paths'=>[], 'aliases'=>{'a1'=>'/dir/a1'})
        @cmd.completion_map.map = {'path1'=>'/dir/path1','path2'=>'/dir/path2'}
      end
      after(:all) { Lightning.config[:aliases] = []}

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

      test "translates alias" do
        translate 'a1', @cmd.completion_map['a1']
      end

      test "translates global alias" do
        translate 'a2', @cmd.completion_map['a2']
      end
    end
  end
end