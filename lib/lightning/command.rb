class Lightning
  class Command < ::Hash
    def initialize(hash)
      super
      replace hash
    end
  end
end