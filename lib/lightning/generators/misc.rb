module Lightning::Generators
  desc "*ALL* files and directories under the current directory. Careful where you do this."
  def wild
    { :globs=> ["**/*"] }
  end

  desc "Files in $PATH"
  def bin
    {:globs=>ENV['PATH'].split(":").uniq.map {|e| "#{e}/*" }}
  end
end