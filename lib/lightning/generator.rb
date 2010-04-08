module Lightning
  # Generates globs for bolts using methods defined in {Generators}.
  # Generated bolts are inserted under Lightning.config[:bolts].
  # Users can define their own generators with {Generators generator plugins}.
  class Generator
    DEFAULT_GENERATORS = %w{gem ruby local_ruby wild}

    # @return [Hash] Maps generators to their descriptions
    def self.generators
      load_plugins
      Generators.generators
    end

    # Runs generators
    # @param [Array<String>] Generators instance methods
    # @param [Hash] options
    # @option options [String] :once Generator to run once
    # @option options [Boolean] :test Runs generators in test mode which only displays
    #   generated globs and doesn't save them
    def self.run(gens=[], options={})
      load_plugins
      new.run(gens, options)
    rescue
      $stderr.puts "Error: #{$!.message}"
    end

    # Loads default and user generator plugins
    def self.load_plugins
      @loaded ||= begin
        Util.load_plugins File.dirname(__FILE__), 'generators'
        Util.load_plugins Lightning.dir, 'generators'
        true
      end
    end

    # Object used to call generator(s)
    attr_reader :underling
    def initialize
      @underling = Object.new.extend(Generators)
    end

    # @return [nil, true] Main method which runs generators
    def run(gens, options)
      if options.key?(:once)
        run_once(gens, options)
      else
        gens = DEFAULT_GENERATORS if Array(gens).empty?
        gens = Hash[*gens.zip(gens).flatten] if gens.is_a?(Array)
        generate_bolts gens
      end
    end

    protected
    def run_once(bolt, options)
      generator = options[:once] || bolt
      if options[:test]
        puts Config.bolt(Array(call_generator(generator)))['globs']
      else
        if generate_bolts(bolt=>generator)
          puts "Generated following globs for bolt '#{bolt}':"
          puts Lightning.config.bolts[bolt]['globs'].map {|e| "  "+e }
          true
        end
      end
    end

    def generate_bolts(bolts)
      results = bolts.map {|bolt, gen|
        (globs = call_generator(gen)) && Lightning.config.bolts[bolt.to_s] = Config.bolt(globs)
      }
      Lightning.config.save if results.any?
      results.all?
    end

    def call_generator(gen)
      raise "Generator method doesn't exist." unless @underling.respond_to?(gen)
      Array(@underling.send(gen)).map {|e| e.to_s }
    rescue
      $stdout.puts "Generator '#{gen}' failed with: #{$!.message}"
    end
  end
end