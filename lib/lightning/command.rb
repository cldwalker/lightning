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
      translated = args.map {|e|
        new_val = completion_map[e] || e
        new_val += self['post_path'] if self['post_path'] && new_val != e
        new_val
      }.join(' ')
      self['add_to_command'] ? translated + self['add_to_command'] : translated
    end
  end
end