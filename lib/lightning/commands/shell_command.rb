module Lightning::Commands
  protected
  meta '(list [-a|--alias] | create SHELL_COMMAND [alias]| delete SHELL_COMMAND)',
    'Commands for managing shell commands. Defaults to listing them.'
  def shell_command(argv)
    subcommand = argv.shift || 'list'
    subcommand = %w{create delete list}.find {|e| e[/^#{subcommand}/]} || subcommand
    shell_command_subcommand(subcommand, argv) if subcommand_has_required_args(subcommand, argv)
  end

  protected
  def shell_command_subcommand(subcommand, argv)
    case subcommand
    when 'list'   then   list_subcommand(:shell_commands, argv)
    when 'create' then   config.create_shell_command(argv[0], argv[1])
    when 'delete' then   config.delete_shell_command(argv[0])
    else  puts "Invalid subcommand '#{subcommand}'", command_usage
    end
  end
end
