require File.join(File.dirname(__FILE__), 'test_helper')

class Lightning
  class CommandTest < Test::Unit::TestCase
    context "Command" do
      before(:all) do
        Lightning.config[:aliases] = {'a2'=>'/dir/a2'}
        @cmd = Command.new('name'=>'blah', 'paths'=>[], 'aliases'=>{'a1'=>'/dir/a1'})
        @cmd.completion_map.map = {'path1'=>'/dir/path1','path2'=>'/dir/path2'}
        @map = @cmd.completion_map
      end
      after(:all) { Lightning.config[:aliases] = []}

      def translate(input, expected)
        Lightning.commands['blah'] = @cmd
        mock(Cli).exit(0)
        mock(Cli).puts(expected)
        Cli.translate_command ['blah'] + input.split(' ')
      end

      test "translates a completion" do
        translate 'path1', @map['path1']
      end

      test "translates a completion with test flag" do
        translate '-test path1', @map['path1']
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

      test "translates alias" do
        translate 'a1', @map['a1']
      end

      test "translates global alias" do
        translate 'a2', @map['a2']
      end
    end
  end
end