require File.join(File.dirname(__FILE__), 'test_helper')

class Lightning
  class GeneratorTest < Test::Unit::TestCase
    context "Generator" do
      def generate(*bolts)
        Cli.generate_command bolts
      end

      def setup_config_file
        old_config_file = Config.config_file
        new_config_file = File.dirname(__FILE__) + '/another_lightning.yml'
        Config.config_file = new_config_file
        yield(new_config_file)
        Config.config_file = old_config_file
        FileUtils.rm_f new_config_file
      end

      test "loads plugin file if it exists" do
        mock(Generator).run
        mock(File).exists?(anything) {true}
        mock(Cli).load anything
        generate
      end

      test "generates all default generators" do
        stub.instance_of(Generator).` { "path1:path2" } #`
        setup_config_file do |config_file|
          generate
          config = YAML::load_file(config_file)
          assert Generator::DEFAULT_GENERATORS.all? {|e| config[:bolts].key?(e) }
        end
      end

      test "defaults to config :default_generators" do
        Lightning.config[:default_generators] = ['gem']
        mock(Generator).generate_bolts(['gem'])
        generate
        Lightning.config[:default_generators] = nil
      end

      test "prints nonexistant generators while continuing with good generators" do
        mock($stdout).puts(/ignored: bad/)
        mock(Generator).generate_bolts([:gem])
        generate :gem, :bad
      end

      test "handles invalid bolt returned by generator" do
        Generators.send(:define_method, :returns_array) { ['not valid bolt']}
        mock(Lightning.config).save
        mock($stderr).puts(/^Error:.*'returns_array'/)
        generate :returns_array
      end

      test "handles unexpected error while generating bolts" do
        mock(Generator).generate_bolts(anything) { raise "Totally unexpected" }
        mock($stderr).puts(/Error: Totally/)
        generate :gem
      end

      context "generates" do
        before(:all) {
          Lightning.config[:bolts]['wild_dir'] = {:paths=>['overwrite me']}
          Generators.send(:define_method, :user_bolt) { {:paths=>['glob1', 'glob2']} }
          mock(Lightning.config).save
          generate 'wild', 'user_bolt', 'wild_dir'
        }

        test "a default bolt" do
          Lightning.config[:bolts]['wild'][:paths].should == ['**/*']
          Lightning.config[:bolts]['wild'][:desc].should =~ /files/
        end

        test "a user-specified bolt" do
          Lightning.config[:bolts]['user_bolt'][:paths].should == ['glob1', 'glob2']
        end

        test "and overwrites existing bolts" do
          Lightning.config[:bolts]['wild_dir'][:paths].should == ["**/"]
        end

        test "and preserves bolts that aren't being generated" do
          Lightning.config[:bolts]['app'].class.should == Hash
        end
      end
    end
  end
end