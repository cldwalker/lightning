# Hash of bolts accessed by their keys
class Lightning
  class Bolts
    def initialize
      @hash = {}
    end
  
    def [](key)
      @hash[key] ||= Lightning::Bolt.new(key)
    end    
  end
end