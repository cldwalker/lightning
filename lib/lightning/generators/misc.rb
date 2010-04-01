module Lightning::Generators
  def wild
    { :globs=> ["**/*"],
      :desc=>"*ALL* files and directories under the current directory. Careful where you do this." }
  end

  def bin
    {:globs=>ENV['PATH'].split(":").uniq.map {|e| "#{e}/*" }, :desc=>"system executables in ENV['PATH']." }
  end
end