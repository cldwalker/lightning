require File.join(File.dirname(__FILE__), 'test_helper')

class Lightning::CompletionMapTest < Test::Unit::TestCase

  context "CompletionMap" do    
    def create_map(path_hash, new_options={})
      stub(Dir).glob { path_hash.values }
      @completion_map = Lightning::CompletionMap.new('blah', new_options)
    end
    
    test "creates basic map" do
      expected_map = {"path1"=>"/dir1/path1", "path2"=>"/dir1/path2"}
      create_map(expected_map)
      assert_equal expected_map, @completion_map.map
    end
    
    test "ignores paths from Lightning.ignore_paths" do
      mock(Lightning::CompletionMap).ignore_paths { ['path1'] }
      expected_map = {"path1"=>"/dir1/path1", "path2"=>"/dir1/path2"}
      create_map(expected_map)
      assert_equal expected_map.slice('path2'), @completion_map.map
    end
    
    test "creates map with duplicates" do
      expected_map = {"path1//dir3"=>"/dir3/path1", "path2"=>"/dir1/path2", "path1//dir1"=>"/dir1/path1", "path1//dir2"=>"/dir2/path1"}
      create_map(expected_map)
      assert_equal expected_map, @completion_map.map
    end
    
    test "fetches correct path completion" do
      map = {"path1"=>"/dir1/path1", "path2"=>"/dir1/path2"}
      create_map(map)
      assert_equal '/dir1/path1', @completion_map['path1']
    end
    
    test "creates alias map" do
      create_map({}, :aliases=>{'path3'=>'/dir1/path3'}, :global_aliases=>{'path2'=>'/dir1/path2'})
      assert_equal({"path2"=>"/dir1/path2", "path3"=>"/dir1/path3"}, @completion_map.alias_map)
    end
    
    test "fetches correct alias completion" do
      create_map({}, :aliases=>{'path3'=>'/dir1/path3'})
      assert_equal '/dir1/path3', @completion_map['path3']
    end
    
    test "fetches correct global alias completion" do
      map = {"path1"=>"/dir1/path1", "path2"=>"/dir1/path2"}
      create_map(map, :global_aliases=>{'path3'=>'/dir1/path3'})
      assert_equal '/dir1/path3', @completion_map['path3']
    end
    
    test "keys include aliases" do
      map = {"path2"=>"/dir1/path2"}
      create_map(map, :global_aliases=>{'path3'=>'/dir1/path3'})
      assert_arrays_equal ['path2','path3'], @completion_map.keys
    end
  end
end
