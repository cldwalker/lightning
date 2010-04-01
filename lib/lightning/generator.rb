module Lightning
  # Generates hashes of bolt attributes using methods defined in Generators.
  # Bolt hashes are inserted under config[:bolts] and Config.config_file is saved.
  class Generator
    DEFAULT_GENERATORS = %w{gem gem_doc ruby local_ruby wild bin}

    # Available generators
    def self.generators
      load_plugins
      Generators.instance_methods(false)
    end

    # Runs generator
    # @param [Array] String which point to instance methods in Generators
    def self.run(gens=[], options={})
      load_plugins
      new.run(gens, options)
    rescue
      $stderr.puts "Error: #{$!.message}"
    end

    def self.load_plugins
      @loaded ||= begin
        Util.load_plugins File.dirname(__FILE__), 'generators'
        Util.load_plugins Lightning.dir, 'generators'
        true
      end
    end

    attr_reader :underling
    def initialize
      @underling = Object.new.extend(Generators)
    end

    def run(gens, options)
      if options.key?(:once)
        run_once(gens, options)
      else
        # @silent = true
        gens = DEFAULT_GENERATORS if Array(gens).empty?
        gens = Hash[*gens.zip(gens).flatten] if gens.is_a?(Array)
        generate_bolts gens
      end
    end

    def run_once(bolt, options)
      if options[:test]
        (result = call_generator(bolt)) && puts(result[:globs])
      else
        if generate_bolts(bolt=>options[:once] || bolt)
          puts "Generated following globs for bolt '#{bolt}':"
          puts Lightning.config.bolts[bolt][:globs].map {|e| "  "+e }
        end
      end
    end

    protected
    def generate_bolts(bolts)
      results = bolts.map {|bolt, gen|
        (bolt_attributes = call_generator(gen)) &&
          Lightning.config.bolts[bolt.to_s] = bolt_attributes
      }
      Lightning.config.save if results.any?
      results.all?
    end

    def call_generator(gen)
      raise "Generator method doesn't exist." unless @underling.respond_to?(gen)
      (result = @underling.send(gen)).is_a?(Hash) ? result :
        $stdout.puts("Generator '#{gen}' did not return a hash as required.") unless @silent
    rescue
      $stdout.puts "Generator '#{gen}' failed with: #{$!.message}" unless @silent
    end
  end
end