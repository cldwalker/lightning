require 'rubygems'
require 'test/unit'
require 'context' #gem install jeremymcanally-context -s http://gems.github.com
require 'rr'
require 'matchy'
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
require 'lightning'
#set up valid global config file
Lightning::Config.config_file = File.join(File.dirname(__FILE__), 'lightning.yml')


class Test::Unit::TestCase
  include RR::Adapters::TestUnit

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