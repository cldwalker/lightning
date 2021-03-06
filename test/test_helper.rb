require 'bacon'
require 'bacon/bits'
require 'rr'
require 'bacon/rr'
require 'lightning'
#set up valid global config file
Lightning::Config.config_file = File.join(File.dirname(__FILE__), 'lightning.yml')
include Lightning

module Helpers
  def config
    Lightning.config
  end

  def run_command(command, args=[])
    Commands.run([command] + args)
  end
  
  def assert_arrays_equal(a1, a2)
    a1.map {|e| e.to_s}.sort.should == a2.map{|e| e.to_s}.sort
  end

  def capture_stdout(&block)
    original_stdout = $stdout
    $stdout = fake = StringIO.new
    begin
      yield
    ensure
      $stdout = original_stdout
    end
    fake.string
  end

  # from ActiveSupport
  def slice_hash(*keys)
    keys.shift.reject { |key,| !keys.include?(key) }
  end

  def translate(fn, input, *expected)
    Lightning.functions['blah'] = fn
    mock(Commands).puts(expected.join("\n"))
    run_command :translate, ['blah'] + input.split(' ')
  end
end

class Bacon::Context
  include Helpers

  def xtest(*args); end
  def xcontext(*args); end
  alias_method :test, :it
  alias_method :context, :describe
end

class <<self
  alias_method :context, :describe
end
