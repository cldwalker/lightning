class Lightning
  class Command < ::Hash
    def initialize(hash)
      super
      replace setup(hash)
    end

    def setup(e)
      #mapping a referenced path
      if e['paths'].is_a?(String)
        e['bolt_key'] = e['paths'].dup
      end
      #create a path entry + key if none exists
      if e['bolt_key'].nil?
        #extract command in case it has options after it
        e['map_to'] =~ /\s*(\w+)/
        bolt_key = commands_to_bolt_key($1, e['name'])
        e['bolt_key'] = bolt_key
        Lightning.bolts[bolt_key].paths = e['paths'] || []
      end
      e
    end

    def commands_to_bolt_key(map_to_command, new_command)
      "#{map_to_command}-#{new_command}"
    end
  end
end