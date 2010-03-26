module Lightning::Commands
  usage 'functions', '', 'Lists functions generated from shell_commands and bolts.'
  def functions_command(argv)
    Lightning.setup
    puts Lightning.functions.keys.sort
  end

  usage 'generators', '', 'Lists available generators.'
  def generators_command(argv)
    puts Lightning::Generator.generators.sort
  end

  def source_file_command(argv)
    puts Lightning.config[:source_file]
  end
end