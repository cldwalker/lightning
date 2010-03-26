module Lightning
  # Generates hashes of bolt attributes using methods defined in Generators.
  # Bolt hashes are inserted under config[:bolts] and Config.config_file is saved.
  class Generator
    DEFAULT_GENERATORS = %w{gem gem_doc system_ruby_file system_ruby_dir local_ruby wild wild_dir}

    # Available generators
    def self.generators
      load_plugin
      Generators.instance_methods(false)
    end

    # Runs generator
    # @param [Array] String which point to instance methods in Generators
    def self.run(gens=[], options={})
      load_plugin
      new.run(gens, options)
    rescue
      $stderr.puts "Error: #{$!.message}"
    end

    def self.load_plugin
      @loaded ||= begin
        plugin_file = File.join(Util.find_home, '.lightning.rb')
        load plugin_file if File.exists? plugin_file
        true
      end
    end

    def initialize
      @underling = Underling.new
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
        (result = call_generator(bolt)) && puts(result[:paths])
      else
        if generate_bolts(bolt=>options[:once] || bolt)
          puts "Generated following paths for bolt '#{bolt}':"
          puts Lightning.config.bolts[bolt][:paths].map {|e| "  "+e }
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

  class Underling
    include Generators

    def `(*args)
      cmd = args[0].split(/\s+/)[0] || ''
      if Util.shell_command_exists?(cmd)
        Kernel.`(*args)
      else
        raise "Command '#{cmd}' doesn't exist."
      end
    end
  end
end