require 'rubygems'
require 'test/unit'
require 'context' #gem
require 'stump' #gem
$LOAD_PATH.unshift(File.dirname(__FILE__) + '/../lib')
require 'lightning'

class Test::Unit::TestCase
end

#from ActiveSupport
class Hash
  def slice(*keys)
    reject { |key,| !keys.include?(key) }
  end
end
