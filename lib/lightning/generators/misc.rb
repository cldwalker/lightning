module Lightning::Generators
  desc "*ALL* files and directories under the current directory. Careful where you do this."
  def wild
    ["**/*"]
  end

  desc "Files in $PATH"
  def bin
    ENV['PATH'].split(":").uniq.map {|e| "#{e}/*" }
  end
end