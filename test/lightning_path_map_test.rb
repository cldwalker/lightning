require File.dirname(__FILE__) + '/test_helper'

class LightningPathMapTest < Test::Unit::TestCase

  context "PathMap" do
    before(:each) { @map = Lightning::PathMap.new }
    
    def stub_dir_glob(path_hash)
      Dir.stub!(:glob) { path_hash.values }
    end
    
    test "creates basic map" do
      expected_map = {"path1"=>"/dir1/path1", "path2"=>"/dir1/path2"}
      stub_dir_glob(expected_map)
      assert_equal expected_map, @map.create_map_for_globs(['any'])
    end
    
    test "ignores paths from Lightning.ignore_paths" do
      Lightning.stub!(:ignore_paths, :return=>['path1'])
      expected_map = {"path1"=>"/dir1/path1", "path2"=>"/dir1/path2"}
      stub_dir_glob(expected_map)
      assert_equal expected_map.slice('path2'), @map.create_map_for_globs(['any'])
    end
    
    test "creates map with duplicates" do
      expected_map = {"path1//dir3"=>"/dir3/path1", "path2"=>"/dir1/path2", "path1//dir1"=>"/dir1/path1", "path1//dir2"=>"/dir2/path1"}
      stub_dir_glob(expected_map)
      assert_equal expected_map, @map.create_map_for_globs(['any'])
    end
  end
end
