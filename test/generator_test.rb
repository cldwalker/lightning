require File.join(File.dirname(__FILE__), 'test_helper')

context "Generator" do

  def generate(*args)
    Generator.run *args
  end

  context "#run" do
    def temporary_config_file
      old_config = config
      old_config_file = Lightning::Config.config_file
      new_config_file = File.dirname(__FILE__) + '/another_lightning.yml'
      Lightning::Config.config_file = new_config_file
      yield(new_config_file)
      Lightning::Config.config_file = old_config_file
      Lightning.config = old_config
      FileUtils.rm_f new_config_file
    end

    test "generates default generators when none given" do
      stub.instance_of(Generator).call_generator { [] }
      temporary_config_file do |config_file|
        generate
        conf = YAML::load_file(config_file)
        Generator::DEFAULT_GENERATORS.all? {|e| conf[:bolts].key?(e) }.should == true
      end
    end

    test "generates given generators" do
      mock.instance_of(Generator).generate_bolts('gem'=>'gem')
      generate ['gem']
    end

    test "handles unexpected error while generating bolts" do
      mock.instance_of(Generator).generate_bolts(anything) { raise "Totally unexpected" }
      mock($stderr).puts(/Error: Totally/)
      generate
    end
  end

  context "#generate_bolts" do
    test "prints error for invalid generator" do
      mock($stdout).puts /'bad' failed.*exist/
      generate ['bad']
    end

    test "handles valid and invalid generators" do
      mock($stdout).puts /'bad' failed.*exist/
      mock(config).save
      generate ['wild', 'bad']
    end

    context "generates" do
      before_all {
        @old_bolts = config[:bolts]
        config[:bolts]['overwrite'] = {'globs'=>['overwrite me']}
        Generators.send(:define_method, :user_bolt) { ['glob1', 'glob2'] }
        Generators.send(:define_method, :overwrite) { ['overwritten'] }
        mock(config).save
        generate ['wild', 'user_bolt', 'overwrite']
      }

      test "a default bolt" do
        config[:bolts]['wild']['globs'].should == ['**/*']
      end

      test "a user-specified bolt" do
        config[:bolts]['user_bolt']['globs'].should == ['glob1', 'glob2']
      end

      test "and overwrites existing bolts" do
        config[:bolts]['overwrite']['globs'].should == ["overwritten"]
      end

      test "and preserves bolts that aren't being generated" do
        config[:bolts]['app'].class.should == Hash
      end

      after_all { config[:bolts] = @old_bolts }
    end
  end

  context "#run with :once" do
    before_all { @old_bolts = config[:bolts] }

    test "and :test generates a test run" do
      mock($stdout).puts ['**/*']
      generate 'wild', :once=>nil, :test=>true
    end

    test "generates a valid bolt" do
      mock($stdout).puts /Generated following/, ["  **/*"]
      mock(config).save
      generate 'wild', :once=>nil
    end

    test "and explicit generator generates a valid bolt" do
      mock($stdout).puts /Generated following/, ["  **/*"]
      mock(config).save
      generate 'blah', :once=>'wild'
    end
    after_all { config[:bolts] = @old_bolts }
  end
end