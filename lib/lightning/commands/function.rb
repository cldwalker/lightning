module Lightning::Commands
  meta '(list | create SHELL_COMMAND BOLT [name])',
    'Commands for managing functions. Defaults to listing them.'
  def function(argv)
    subcommand = argv.shift || 'list'
    subcommand = %w{create list}.find {|e| e[/^#{subcommand}/]} || subcommand
    function_subcommand(subcommand, argv) if subcommand_has_required_args(subcommand, argv)
  end

  def function_subcommand(subcommand, argv)
    case subcommand
    when 'list'    then Lightning.setup; puts Lightning.functions.keys.sort
    when  'create' then Lightning.config.create_function(argv[0], argv[1], :name=>argv[2])
    else puts "Invalid subcommand '#{subcommand}'", command_usage
    end
  end
end