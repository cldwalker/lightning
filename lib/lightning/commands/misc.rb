module Lightning::Commands
  meta '', 'Lists functions generated from shell_commands and bolts.'
  def functions(argv)
    Lightning.setup
    puts Lightning.functions.keys.sort
  end

  meta '', 'Lists available generators.'
  def generators(argv)
    puts Lightning::Generator.generators.sort
  end

  def source_file(argv)
    puts Lightning.config.source_file
  end
end