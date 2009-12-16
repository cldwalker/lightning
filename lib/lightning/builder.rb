#This class builds a shell scripts from a configuration.
class Lightning
  module Builder
    extend self

    HEADER = <<-INIT.gsub(/^\s+/,'')
    #### This file was built by lightning-build. ####
    #LBIN_PATH="$PWD/bin/" #only use for development
    LBIN_PATH=""
    INIT

    def can_build?
      respond_to? "#{shell}_builder"
    end

    def shell
      Lightning.config[:shell] || 'bash'
    end

    def run(source_file)
      commands = Lightning.commands.values
      check_for_existing_commands(commands)
      output = build(commands)
      File.open(source_file || Lightning.config[:source_file], 'w'){|f| f.write(output) }
      output
    end

    def build(*args)
      HEADER + "\n\n" + send("#{shell}_builder", *args)
    end

    def command_header(command)
      (command.desc ? "##{command.desc}\n" : "")
    end

    def bash_builder(commands)
      commands.map do |e|
        command_header(e) +
        <<-EOS.gsub(/^\s{10}/,'')
          #{e.name} () {
            #{e.shell_command} $( ${LBIN_PATH}lightning-translate #{e.name} $@ )
          }
          complete -o default -C "${LBIN_PATH}lightning-complete #{e.name}" #{e.name}
        EOS
      end.join("\n")
    end

    def zsh_builder(commands)
      commands.map do |e|
        command_header(e) +
        <<-EOS.gsub(/^\s{10}/,'')
          #{e.name} () {
            #{e.shell_command} $( ${LBIN_PATH}lightning-translate #{e.name} $@ )
          }
          _#{e.name} () {
            reply=($(${LBIN_PATH}lightning-complete #{e.name} ${@}))
          }
          compctl -K _#{e.name} #{e.name}
        EOS
      end.join("\n")
    end

    def check_for_existing_commands(commands)
      if !(existing_commands = commands.select {|e| Util.shell_command_exists?(e.name) }).empty?
        puts "The following commands already exist in $PATH and are being generated: "+
          "#{existing_commands.map {|e| e.name}.join(', ')}"
      end
    end
  end
end
