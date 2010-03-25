module Lightning
  # Generates hashes of bolt attributes using methods defined in Generators.
  # Bolt hashes are inserted under config[:bolts] and Config.config_file is saved.
  class Generator
    DEFAULT_GENERATORS = %w{gem gem_doc system_ruby_file system_ruby_dir local_ruby wild wild_dir}
    include Generators

    # Runs generator
    # @param [Array] String which point to instance methods in Generators
    def self.run(gens=[])
      gens = DEFAULT_GENERATORS if Array(gens).empty?
      setup
      generate_bolts gens
    rescue
      $stderr.puts "Error: #{$!.message}"
    end

    def self.run_once(bolt, generator=nil)
      setup
      if generate_bolts(bolt=>generator || bolt)
        puts "Generated following paths for bolt '#{bolt}':"
        puts Lightning.config.bolts[bolt][:paths].map {|e| "  "+e }
      end
    end

    # Available generators
    def self.generators
      Generators.instance_methods(false)
    end

    protected
    def self.setup
      plugin_file = File.join(Util.find_home, '.lightning.rb')
      load plugin_file if File.exists? plugin_file
      @generator = self.new
    end

    def self.generate_bolts(bolts)
      bolts = Hash[*bolts.zip(bolts).flatten] if bolts.is_a?(Array)
      results = bolts.map {|bolt, gen|
        (bolt_attributes = call_generator(gen)) &&
          Lightning.config.bolts[bolt.to_s] = bolt_attributes
      }
      Lightning.config.save if results.any?
      results.all?
    end

    def self.call_generator(gen)
      raise "Generator method doesn't exist." unless @generator.respond_to?(gen)
      (result = @generator.send(gen)).is_a?(Hash) ? result :
        $stdout.puts("Generator '#{gen}' did not return a hash as required.")
    rescue
      $stdout.puts "Generator '#{gen}' failed with: #{$!.message}"
    end

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