module Lightning
  # Generates hashes of bolt attributes using methods defined in Generators.
  # Bolt hashes are inserted under config[:bolts] and Config.config_file is saved.
  class Generator
    DEFAULT_GENERATORS = %w{gem gem_doc system_ruby_file system_ruby_dir local_ruby wild wild_dir}
    include Generators

    # Runs generator
    # @param [Array] String which point to instance methods in Generators
    def self.run(*gens)
      setup
      gens = Lightning.config[:default_generators] || DEFAULT_GENERATORS if gens.empty?
      @generator = self.new
      good, bad = gens.partition {|e| @generator.respond_to?(e) }
      $stdout.puts "The following generators don't exist and were ignored: #{bad.join(', ')}" unless bad.empty?
      generate_bolts good
    rescue
      $stderr.puts "Error: #{$!.message}"
    end

    # Available generators
    def self.generators
      Generators.instance_methods(false)
    end

    protected
    def self.setup
      plugin_file = File.join(Util.find_home, '.lightning.rb')
      load plugin_file if File.exists? plugin_file
    end

    def self.generate_bolts(bolts)
      bolts.each do |e|
        if (bolt_attributes = @generator.send(e)).is_a?(Hash)
          Lightning.config[:bolts][e.to_s] = bolt_attributes
        else
          $stderr.puts "Error: The generator '#{e}' did not return a hash as required"
        end
      end
      Lightning.config.save
    end
  end
end