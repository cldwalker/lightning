require 'rubygems'
require 'bacon'
require 'rr'
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
require 'lightning'
#set up valid global config file
Lightning::Config.config_file = File.join(File.dirname(__FILE__), 'lightning.yml')
include Lightning

module Helpers
  def run_command(command, args=[])
    Cli.run([command] + args)
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

module BaconExtensions
  def self.included(mod)
    mod.module_eval do
      # nested context methods automatically inherit methods from parent contexts
      def describe(*args, &block)
        context = Bacon::Context.new(args.join(' '), &block)
        (parent_context = self).methods(false).each {|e|
          class<<context; self end.send(:define_method, e) {|*args| parent_context.send(e, *args)}
        }
        @before.each { |b| context.before(&b) }
        @after.each { |b| context.after(&b) }
        context.run
      end
    end
  end

  def xtest(*args); end
  def xcontext(*args); end
  def before_all; yield; end
  def after_all; yield; end
  def assert(description, &block)
    it(description) do
      block.call.should == true
    end
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

  alias_method :test, :it
  alias_method :context, :describe
end

class <<self
  alias_method :context, :describe
end