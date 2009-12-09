class Lightning
  class Command < ::Hash
    def initialize(hash)
      super
      replace hash
    end

    def completions
      completion_map.keys
    end

    def completion_map
      @completion_map ||= CompletionMap.new(self['paths'], :global_aliases=>Lightning.config[:aliases],
        :aliases=>self['aliases'])
    end

    def translate_completion(args)
      args = Array(args)
      args.shift if args[0] == Lightning::TEST_FLAG
      args.map {|e| completion_map[e] || e }.join(' ')
    end
  end
end