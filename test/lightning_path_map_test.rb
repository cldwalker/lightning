require File.dirname(__FILE__) + '/test_helper'

class LightningPathMapTest < Test::Unit::TestCase

  context "PathMap" do
    before(:each) { @map = Lightning::PathMap.new }
    
    def stub_dir_glob(path_hash)
      Dir.stub!(:glob) { path_hash.values }
    end
    
    test "creates map only once when accessing same key multiple times" do
      # @map.expects(:create_map).once.returns({})
      called = 0
      @map.stub!(:create_map) {|e| called += 1; {}}
      @map['blah']
      @map['blah']
      assert called == 1
    end
    
    test "creates basic map" do
      expected_map = {"path1"=>"/dir1/path1", "path2"=>"/dir1/path2"}
      stub_dir_glob(expected_map)
      assert_equal expected_map, @map.create_map_for_globs(['blah'])
    end
    
    test "ignores paths from Lightning.ignore_paths" do
      Lightning.stub!(:ignore_paths, :return=>['path1'])
      expected_map = {"path1"=>"/dir1/path1", "path2"=>"/dir1/path2"}
      stub_dir_glob(expected_map)
      assert_equal expected_map.slice('path2'), @map.create_map_for_globs(['blah'])
    end
    
    test "creates map with duplicates" do
      expected_map = {"path1//dir3"=>"/dir3/path1", "path2"=>"/dir1/path2", "path1//dir1"=>"/dir1/path1", "path1//dir2"=>"/dir2/path1"}
      stub_dir_glob(expected_map)
      assert_equal expected_map, @map.create_map_for_globs(['blah'])
    end
    
    test "creates hash even for invalid key" do
      @map.create_map('blah').is_a?(Hash)
    end
  end
end
