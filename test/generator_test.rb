require File.join(File.dirname(__FILE__), 'test_helper')

context "Generator" do

  def temporary_config_file
    old_config = Lightning.config
    old_config_file = Lightning::Config.config_file
    new_config_file = File.dirname(__FILE__) + '/another_lightning.yml'
    Lightning::Config.config_file = new_config_file
    yield(new_config_file)
    Lightning::Config.config_file = old_config_file
    Lightning.config = old_config
    FileUtils.rm_f new_config_file
  end

  def generate(*args)
    args[-1].is_a?(Hash) ? args.pop : {}
    Generator.run args, {}
  end

  test "loads plugin file if it exists" do
    mock(File).exists?(anything) {true}
    mock(Generator).load anything
    Generator.load_plugin
  end

  test "generates default generators when none given" do
    stub.instance_of(Generator).call_generator { { }}
    temporary_config_file do |config_file|
      generate
      config = YAML::load_file(config_file)
      Generator::DEFAULT_GENERATORS.all? {|e| config[:bolts].key?(e) }.should == true
    end
  end

  test "generates given generators" do
    mock.instance_of(Generator).generate_bolts('gem'=>'gem')
    generate 'gem'
  end

  test "prints nonexistant generators while continuing with good generators" do
    stub.instance_of(Underling).` { {} } #`
    capture_stdout {
      generate :gem, :bad
    }.should =~ /^Generator 'bad' failed/
  end

  test "handles invalid bolt returned by generator" do
    Generators.send(:define_method, :returns_array) { ['not valid bolt']}
    mock(Lightning.config).save.never
    mock($stdout).puts(/^Generator.*'returns_array'/)
    generate :returns_array
  end

  test "handles unexpected error while generating bolts" do
    mock.instance_of(Generator).generate_bolts(anything) { raise "Totally unexpected" }
    mock($stderr).puts(/Error: Totally/)
    generate :gem
  end

  context "generates" do
    before_all {
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