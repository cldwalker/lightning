class Lightning
  # This module contains methods which are used to generate bolts with lightning-generate.
  # Each method should return a hash of bolt attributes. A bolt hash should at least have a paths
  # attribute. The name of the method is the name given to the bolt.
  module Generators
    def gem
      {
        :paths=>`gem environment path`.split(":").map {|e| e +"/gems/*" },
        :desc=>"source code of gems"
      }
    end

    def gem_doc
      {
        :paths=>`gem environment path`.split(":").map {|e| e +"/doc/*" },
        :commands=>[ {'shell_command'=>'open', 'desc'=>"open a gem's documentation in a browser",
          'post_path'=>'/rdoc/index.html' }]
      }
    end

    def system_ruby_file
      { :paths=>system_ruby.map {|e| e +"/**/*.{rb,bundle,so,c}"} }
    end

    def system_ruby_dir
      { :paths=>system_ruby.map {|e| e +"/**/"} }
    end

    def local_ruby
      { :paths=>["**/*.rb", "bin/**"], :desc=>"local files in a ruby project i.e. a gem" }
    end

    def wild
      {
        :paths=> ["**/*"],
        :desc=>"*ALL* files and directories under the current directory. Careful where you do this."
      }
    end

    def wild_dir
      {
        :paths=>["**/"],
        :desc=>"*ALL* directories under the current directory. Careful where you do this."
      }
    end

    private
    def system_ruby
      require 'rbconfig'
      [RbConfig::CONFIG['rubylibdir'], RbConfig::CONFIG['sitelibdir']].compact.uniq
    end
  end
end