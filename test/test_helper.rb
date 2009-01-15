require 'rubygems'
require 'test/unit'
require 'context' #gem
require 'stump' #gem
$LOAD_PATH.unshift(File.dirname(__FILE__) + '/../lib')
require 'lightning'

class Test::Unit::TestCase
  def assert_arrays_equal(a1, a2)
    assert_equal a1.map {|e| e.to_s}.sort, a2.map{|e| e.to_s}.sort
  end
  
end

#from ActiveSupport
class Hash
  def slice(*keys)
    reject { |key,| !keys.include?(key) }
  end
end
