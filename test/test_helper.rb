require 'rubygems'
# require 'test/unit'
# require 'context' #gem install jeremymcanally-context -s http://gems.github.com
require 'protest'
def context(*args,&block); Protest.context(*args,&block); end
require 'rr'
# require 'matchy'
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
require 'lightning'
#set up valid global config file
Lightning::Config.config_file = File.join(File.dirname(__FILE__), 'lightning.yml')

class Object
  def should(expectation)
    expectation.match?(self)
  end
end

module Matchers
  class EqualityMatcher
    def initialize(expected, test_case)
      @expected = expected
      @test_case = test_case
    end

    def match?(actual)
      @test_case.assert(@expected == actual)
    end
  end

  def equal(expected)
    EqualityMatcher.new(expected, self)
  end
  alias_method :==, :equal
end

class Protest::TestCase
  include Matchers
  include RR::Adapters::TestUnit

  def run_command(*args)
    Lightning::Cli.run_command(*args)
  end

  def assert_arrays_equal(a1, a2)
    assert_equal a1.map {|e| e.to_s}.sort, a2.map{|e| e.to_s}.sort
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
end