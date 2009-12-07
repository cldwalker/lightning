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

    def translate_completion(basename)
      basename = basename.join(" ") if basename.is_a?(Array)
      basename.gsub!(/\s*#{TEST_FLAG}\s*/,'')
      #TODO
      # if (regex = self['completion_regex'])
      #   basename = basename[/#{regex}/]
      # end
      completion_map[basename] || ''
    end
  end
end