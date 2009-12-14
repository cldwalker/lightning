#This class builds a shell scripts from a configuration.
class Lightning
  module Builder
    extend self

    HEADER = <<-INIT.gsub(/^\s+/,'')
    #### This file was built by Lightning. ####
    #LBIN_PATH="$PWD/bin/" #only use for development
    LBIN_PATH=""
    INIT

    def can_build?
      respond_to? "#{shell}_builder"
    end

    def shell
      Lightning.config[:shell] || 'bash'
    end

    def run(generated_file)
      generated_file ||= Lightning.config[:generated_file]
      Cli.read_config
      output = build(Lightning.commands.values)
      File.open(generated_file, 'w'){|f| f.write(output) }
      output
    end

    def build(*args)
      HEADER + "\n\n" + send("#{shell}_builder", *args)
    end
    
    def bash_builder(commands)
      commands.map do |e|
        <<-EOS
          #{'#' + e.desc if e.desc}
          #{e.name} () {
            #{e.shell_command} `${LBIN_PATH}lightning-translate #{e.name} $@`
          }
          complete -o default -C "${LBIN_PATH}lightning-complete #{e.name}" #{e.name}
        EOS
      end.join("\n").gsub(/^\s{6,10}/, '')
    end
  end
end
