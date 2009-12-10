require File.join(File.dirname(__FILE__), 'test_helper')

class Lightning::CompletionMapTest < Test::Unit::TestCase

  context "CompletionMap" do    
    def create_map(path_hash, new_options={})
      stub(Dir).glob('blah/*', File::FNM_DOTMATCH) { path_hash.values }
      @completion_map = Lightning::CompletionMap.new('blah/*', new_options)
    end
    
    test "creates basic map" do
      expected_map = {"path1"=>"/dir1/path1", "path2"=>"/dir1/path2"}
      create_map(expected_map)
      assert_equal expected_map, @completion_map.map
    end
    
    test "ignores paths from Lightning.ignore_basenames" do
      Lightning::CompletionMap.ignore_basenames = ['path1']
      expected_map = {"path1"=>"/dir1/path1", "path2"=>"/dir1/path2"}
      create_map(expected_map)
      assert_equal slice_hash(expected_map, 'path2'), @completion_map.map
    end
    
    test "creates map with duplicates" do
      expected_map = {"path1//dir3"=>"/dir3/path1", "path2"=>"/dir1/path2", "path1//dir1"=>"/dir1/path1", "path1//dir2"=>"/dir2/path1"}
      create_map(expected_map)
      assert_equal expected_map, @completion_map.map
    end
  end
end
