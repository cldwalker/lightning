require 'rubygems'
require 'bacon'
# require 'test/unit'
# require 'context' #gem install jeremymcanally-context -s http://gems.github.com
# require 'protest'
# def context(*args,&block); Protest.context(*args,&block); end
require 'rr'
# require 'matchy'
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
require 'lightning'
#set up valid global config file
Lightning::Config.config_file = File.join(File.dirname(__FILE__), 'lightning.yml')

module Helpers
  def run_command(*args)
    Lightning::Cli.run_command(*args)
  end
  
  def generate(*bolts)
    run_command :generate, bolts
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

module BaconExtensions
  def before_all; yield; end
  def after_all; yield; end
  def assert(description, &block)
    it(description) do
      block.call.should == true
    end
  end
end

class Bacon::Context
  # overrides describe to automatic inherited behaviors as methods
  def describe(*args, &block)
    context = Bacon::Context.new(args.join(' '), &block)
    (parent_context = self).methods(false).each {|e|
      class<<context; self end.send(:define_method, e) {|*args| parent_context.send(e, *args)}
    }
    @before.each { |b| context.before(&b) }
    @after.each { |b| context.after(&b) }
    context.run
  end

  include Helpers
  include BaconExtensions

  # RR adapter
  include RR::Adapters::RRMethods
  RR.trim_backtrace = true
  alias_method :old_it, :it
	def it(description)
    old_it(description) do
      RR.reset
      # Add at least one requirement to ensure mock-only tests don't fail
      Bacon::Counter[:requirements] += 1
      yield
      Bacon::Counter[:requirements] -= 1 if RR.double_injections.size.zero?
      RR.verify
    end
	end

  alias_method :test, :it
  alias_method :context, :describe
end

class <<self
  alias_method :context, :describe
end

__END__
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

end