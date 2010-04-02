module Lightning::Generators
  desc "Directories of gems"
  def gem
    `gem environment path`.chomp.split(":").map {|e| e +"/gems/*" }
  end

  desc "System ruby files"
  def ruby
    system_ruby.map {|e| e +"/**/*.{rb,bundle,so,c}"}
  end

  desc "Files in a rails project"
  def rails
    ["{app,config,lib}/**/*", "{db}/**/*.rb"]
  end

  desc "*ALL* local ruby files. Careful where you do this."
  def local_ruby
    ["**/*.rb", "bin/*"]
  end

  desc "Test or spec files in a ruby project"
  def test_ruby
    ['{spec,test}/**/*_{test,spec}.rb', '{spec,test}/**/{test,spec}_*.rb', 'spec/**/*.spec']
  end

  private
  def system_ruby
    require 'rbconfig'
    [RbConfig::CONFIG['rubylibdir'], RbConfig::CONFIG['sitelibdir']].compact.uniq
  end
end