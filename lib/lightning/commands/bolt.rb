module Lightning::Commands
  meta "(list [-a|--alias] | add BOLT GLOBS | alias BOLT ALIAS | "+
    "delete BOLT | generate BOLT [generator] [-t|--test] | show BOLT)",
    "Commands for managing bolts. Defaults to listing them."
  def bolt(argv)
    subcommand = argv.shift || 'list'
    subcommand = %w{add alias delete generate list show}.find {|e| e[/^#{subcommand}/]} || subcommand
    bolt_subcommand(subcommand, argv) if subcommand_has_required_args(subcommand, argv)
  end

  def bolt_subcommand(subcommand, argv)
    case subcommand
    when 'list'     then    list_subcommand(:bolts, argv)
    when 'add'      then    Lightning.config.add_bolt(argv.shift, argv)
    when 'alias'    then    Lightning.config.alias_bolt(argv[0], argv[1])
    when 'delete'   then    Lightning.config.delete_bolt(argv[0])
    when 'show'     then    Lightning.config.show_bolt(argv[0])
    when 'generate'
      Lightning::Generator.run(argv[0], :once=>argv[1], :test=>!(argv & %w{-t --test}).empty?)
    else puts "Invalid subcommand '#{subcommand}'", command_usage
    end
  end
end