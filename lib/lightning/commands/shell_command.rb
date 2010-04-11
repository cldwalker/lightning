module Lightning::Commands
  protected
  desc '(list [-a|--alias] | create SHELL_COMMAND [alias]| delete SHELL_COMMAND)',
    'Commands for managing shell commands. Defaults to listing them.'
  def shell_command(argv)
    call_subcommand(argv, %w{create delete list}) do |scmd, argv|
      case scmd
      when 'list'   then   list_subcommand(:shell_commands, argv)
      when 'create' then   create_shell_command(argv[0], argv[1])
      when 'delete' then   delete_shell_command(argv[0])
      end
    end
  end

  def create_shell_command(scmd, scmd_alias=nil)
    scmd_alias ||= scmd
    if config.shell_commands.values.include?(scmd_alias)
      puts "Alias '#{scmd_alias}' already exists for shell command '#{config.unaliased_command(scmd_alias)}'"
    else
      config.shell_commands[scmd] = scmd_alias
      save_and_say "Created shell command '#{scmd}'"
    end
  end

  def delete_shell_command(scmd)
    if config.shell_commands[scmd]
      config.shell_commands.delete scmd
      save_and_say "Deleted shell command '#{scmd}' and its functions"
    else
      puts "Can't find shell command '#{scmd}'"
    end
  end
end
