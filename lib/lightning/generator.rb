#This class generates shell scripts from a configuration.
class Lightning
  class Generator
    class<<self
    def generate_completions
      output = generate(Lightning.config[:shell], Lightning.config[:commands])
      File.open(Lightning.config[:generated_file], 'w'){|f| f.write(output) }
      output
    end
          
    def generate(*args)
      shell = args.shift
      send("#{shell}_generator", *args)
    end
    
    def bash_generator(commands)
      body = <<-INIT
      #### This file was generated by Lightning. ####
      #LBIN_PATH="$PWD/bin/" #only use for development
      LBIN_PATH="" 
      
      INIT
      commands.each do |e|
        body += <<-EOS
          
          #{'#' + e['description'] if e['description']}
          #{e['name']} () {
            FULL_PATH="`${LBIN_PATH}lightning-full_path #{e['path_key']} $@`#{e['post_path'] if e['post_path']}"
            if [ $1 == '#{Lightning::TEST_FLAG}' ]; then
              CMD="#{e['map_to']} '$FULL_PATH'#{' '+ e['add_to_command'] if e['add_to_command']}"
              echo $CMD
            else
              #{e['map_to']} "$FULL_PATH"#{' '+ e['add_to_command'] if e['add_to_command']}
            fi
          }
          complete -o default -C "${LBIN_PATH}lightning-complete #{e['path_key']}" #{e['name']}
        EOS
      end
      body.gsub(/^\s{6,10}/, '')
    end
    end
  end
end
