module Lightning::Generators
  def gem
    { :paths=>`gem environment path`.chomp.split(":").map {|e| e +"/gems/*" },
      :desc=>"source code of gems" }
  end

  def gem_doc
    { :paths=>`gem environment path`.chomp.split(":").map {|e| e +"/doc/*" },
      :commands=>[ {'shell_command'=>'open', 'desc'=>"open a gem's documentation in a browser",
        'post_path'=>'/rdoc/index.html', 'name'=>'gem-doc' } ] }
  end

  def ruby
    { :paths=>system_ruby.map {|e| e +"/**/*.{rb,bundle,so,c}"} }
  end

  def local_ruby
    { :paths=>["**/*.rb", "bin/**"], :desc=>"local files in a ruby project i.e. a gem" }
  end

  def test_ruby
    { :paths=>['{spec,test}/**/*_{test,spec}.rb', '{spec,test}/**/{test,spec}_*.rb', 'spec/**/*.spec'],
    :desc=>"test or spec files in a test suite"}
  end

  private
  def system_ruby
    require 'rbconfig'
    [RbConfig::CONFIG['rubylibdir'], RbConfig::CONFIG['sitelibdir']].compact.uniq
  end
end