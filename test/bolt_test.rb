require File.join(File.dirname(__FILE__), 'test_helper')

class Lightning::BoltTest < Test::Unit::TestCase
  context "Bolt" do
    before(:each) do
      @completion_map = {'path1'=>'/dir/path1','path2'=>'/dir/path2'}
      @bolt = Lightning::Bolt.new('blah')
      @bolt.completion_map.map = @completion_map
    end
    
    test "fetches correct completions" do
      assert_equal @bolt.completions, @completion_map.keys
    end

    test "resolves completion" do
      assert_equal @completion_map['path1'], @bolt.resolve_completion('path1')
    end

    test "resolves completion with test flag" do
      assert_equal @completion_map['path1'], @bolt.resolve_completion('-test path1')
    end

    test "creates completion_map only once" do
      assert_equal @bolt.completion_map.object_id, @bolt.completion_map.object_id
    end
  end
end
