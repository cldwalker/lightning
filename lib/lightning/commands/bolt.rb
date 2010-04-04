module Lightning::Commands
  meta "(list [-a|--alias] | alias BOLT ALIAS | create BOLT GLOBS | delete BOLT |\n#{' '*22} "+
    "generate BOLT [generator] [-t|--test] | global ON_OR_OFF BOLTS | show BOLT)",
    "Commands for managing bolts. Defaults to listing them."
  def bolt(argv)
    subcommand = argv.shift || 'list'
    subcommand = %w{alias create delete generate global list show}.find {|e| e[/^#{subcommand}/]} || subcommand
    bolt_subcommand(subcommand, argv) if subcommand_has_required_args(subcommand, argv)
  end

  def bolt_subcommand(subcommand, argv)
    case subcommand
    when 'list'     then    list_subcommand(:bolts, argv)
    when 'create'   then    config.create_bolt(argv.shift, argv)
    when 'alias'    then    config.alias_bolt(argv[0], argv[1])
    when 'delete'   then    config.delete_bolt(argv[0])
    when 'show'     then    config.show_bolt(argv[0])
    when 'global'   then    config.globalize_bolts(argv.shift, argv)
    when 'generate'
      args, options = parse_args argv
      Lightning::Generator.run(args[0], :once=>args[1], :test=>options[:test] || options[:t])
    else puts "Invalid subcommand '#{subcommand}'", command_usage
    end
  end
end