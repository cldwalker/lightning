require File.join(File.dirname(__FILE__), 'test_helper')

class Lightning::CommandTest < Test::Unit::TestCase
  context "Command" do
    before(:each) do
      @completion_map = {'path1'=>'/dir/path1','path2'=>'/dir/path2'}
      @bolt = Lightning::Command.new('name'=>'blah', 'paths'=>[])
      @bolt.completion_map.map = @completion_map
    end
    
    test "fetches correct completions" do
      assert_equal @bolt.completions, @completion_map.keys
    end

    test "resolves completion" do
      assert_equal @completion_map['path1'], @bolt.translate_completion('path1')
    end

    test "resolves completion with test flag" do
      assert_equal @completion_map['path1'], @bolt.translate_completion('-test path1')
    end

    test "creates completion_map only once" do
      assert_equal @bolt.completion_map.object_id, @bolt.completion_map.object_id
    end
  end
  
  test "Command's completion_map sets up alias map with options" do
    old_config = Lightning.config
    Lightning.config = Lightning::Config.new({:aliases=>{'path1'=>'/dir1/path1'}, :commands=>[{'name'=>'blah'}], :paths=>{}})
    @bolt = Lightning::Command.new('name'=>'blah', 'paths'=>[])
    assert_equal({'path1'=>'/dir1/path1'}, @bolt.completion_map.alias_map)
    Lightning.config = Lightning::Config.new(old_config)
  end
end
