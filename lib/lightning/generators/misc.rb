module Lightning::Generators
  def wild
    { :paths=> ["**/*"],
      :desc=>"*ALL* files and directories under the current directory. Careful where you do this." }
  end

  def bin
    {:paths=>ENV['PATH'].split(":").uniq.map {|e| "#{e}/*" }, :desc=>"system executables in ENV['PATH']." }
  end
end