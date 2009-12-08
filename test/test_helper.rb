require 'rubygems'
require 'test/unit'
require 'context' #gem install jeremymcanally-context -s http://gems.github.com
require 'stump' #gem install jeremymcanally-stump -s http://gems.github.com
require 'matchy'
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
require 'lightning'
#set up valid global config file
Lightning::Config.config_file = File.join(File.dirname(__FILE__), 'lightning.yml')


class Test::Unit::TestCase
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
end

#from ActiveSupport
class Hash
  def slice(*keys)
    reject { |key,| !keys.include?(key) }
  end
end
