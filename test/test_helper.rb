require 'bacon'
require 'rr'
require File.dirname(__FILE__)+'/bacon_extensions'
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
end

class Bacon::Context
  include Helpers
  include BaconExtensions

  # RR adapter
  def self.silent?
    @silent ||= class << Bacon; self; end.ancestors.include?(Bacon::TestUnitOutput)
  end
  include RR::Adapters::RRMethods
  RR.trim_backtrace = true
  alias_method :old_it, :it
	def it(description)
    old_it(description) do
      # Add at least one requirement to ensure mock-only tests don't fail
      Bacon::Counter[:requirements] += 1
      yield
      Bacon::Counter[:requirements] -= 1 if RR.double_injections.size.zero?
      RR.verify unless self.class.silent?
      RR.reset
    end
	end

  def xtest(*args); end
  def xcontext(*args); end
  alias_method :test, :it
  alias_method :context, :describe
end

class <<self
  alias_method :context, :describe
end