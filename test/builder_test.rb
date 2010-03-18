require File.join(File.dirname(__FILE__), 'test_helper')

# class Lightning
#   class BuilderTest < Test::Unit::TestCase
# class Protest::TestCase
#     def self.build
#       Lightning::Cli.run_command :build, [@source_file]
#     end
# end
    context "Builder" do
      SOURCE_FILE = File.dirname(__FILE__) + '/lightning_completions'
      setup do
        @source_file =  File.dirname(__FILE__) + '/lightning_completions'
      end
      global_teardown {  FileUtils.rm_f(SOURCE_FILE) }

      def build
        run_command :build, [@source_file]
      end

      context "with default shell" do
        global_setup { build }

        test "builds file in expected location" do
          assert File.exists?(@source_file)
        end

        # depends on test/lightning.yml
        test "builds expected output for a command" do
          expected = <<-EOS.gsub(/^\s{10}/,'')
          #open mac applications
          oa () {
            local IFS=$'\\n'
            local arr=( $(${LBIN_PATH}lightning-translate oa $@) )
            open -a "${arr[@]}"
          }
          complete -o default -C "${LBIN_PATH}lightning-complete oa" oa
          EOS
          assert File.read(@source_file).include?(expected)
        end
      end

      test "with non-default shell builds" do
        Lightning.config[:shell] = 'zsh'
        mock(Lightning::Builder).zsh_builder(anything) { '' }
        build
        Lightning.config[:shell] = nil
      end

      test "warns about existing commands being overridden" do
        mock(Lightning::Util).shell_command_exists?('bling') { true }
        stub(Lightning::Util).shell_command_exists?(anything) { false }
        capture_stdout { build } =~ /following.*exist.*: bling$/
      end
    end
#   end
# end