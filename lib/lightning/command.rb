class Lightning
  class Command < ::Hash
    def initialize(hash)
      super
      replace setup(hash)
    end

    def setup(e)
      #mapping a referenced path
      if e['paths'].is_a?(String)
        e['bolt'] = e['paths'].dup
      end
      #create a path entry + key if none exists
      if e['bolt'].nil?
        #extract command in case it has options after it
        e['map_to'] =~ /\s*(\w+)/
        bolt = command_to_bolt($1, e['name'])
        e['bolt'] = bolt
        Lightning.bolts[bolt].paths = e['paths'] || []
      end
      e
    end

    def command_to_bolt(map_to_command, new_command)
      "#{map_to_command}-#{new_command}"
    end
  end
end