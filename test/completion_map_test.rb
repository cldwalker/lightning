require File.join(File.dirname(__FILE__), 'test_helper')

class Lightning
  class CompletionMapTest < Test::Unit::TestCase

    context "CompletionMap" do
      def create_map(path_hash, new_options={})
        stub(Dir).glob('blah/*', File::FNM_DOTMATCH) { path_hash.values }
        @completion_map = CompletionMap.new('blah/*', new_options)
      end
    
      test "creates basic map" do
        expected_map = {"path1"=>"/dir1/path1", "path2"=>"/dir1/path2"}
        create_map(expected_map)
        assert_equal expected_map, @completion_map.map
      end
    
      test "ignores paths from Lightning.ignore_paths" do
        CompletionMap.ignore_paths = ['path1', 'dir2', '\.\.?$']
        expected_map = {"path1"=>"/dir1/path1", "path2"=>"/dir1/path2", 'path3'=>'/dir2/path3', '.'=>'/dir1/path4/.'}
        create_map(expected_map)
        assert_equal slice_hash(expected_map, 'path2'), @completion_map.map
      end
    
      test "creates map with duplicates" do
        expected_map = {"path1///dir3"=>"/dir3/path1", "path2"=>"/dir1/path2", "path1///dir1"=>"/dir1/path1", "path1///dir2"=>"/dir2/path1"}
        create_map(expected_map)
        assert_equal expected_map, @completion_map.map
      end

      test "ignores duplicate paths created by overlapping globs" do
        mock(Dir).glob('/usr/**', File::FNM_DOTMATCH) { ['/usr/lib/path1', '/usr/lib/path2'] }
        mock(Dir).glob('/usr/lib/*', File::FNM_DOTMATCH) { ['/usr/lib/path1'] }
        @completion_map = CompletionMap.new('/usr/**', '/usr/lib/*')
        @completion_map.map.should == {'path1'=>'/usr/lib/path1', 'path2'=>'/usr/lib/path2'}
      end
    end
  end
end
