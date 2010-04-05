module Lightning::Commands
  protected
  desc "(list [-a|--alias] | alias BOLT ALIAS | create BOLT GLOBS | delete BOLT |\n#{' '*22} "+
    "generate BOLT [generator] [-t|--test] | global ON_OR_OFF BOLTS | show BOLT)",
    "Commands for managing bolts. Defaults to listing them."
  def bolt(argv)
    subcommand = argv.shift || 'list'
    subcommand = %w{alias create delete generate global list show}.find {|e| e[/^#{subcommand}/]} || subcommand
    bolt_subcommand(subcommand, argv) if subcommand_has_required_args(subcommand, argv)
  end

  def bolt_subcommand(subcommand, argv)
    case subcommand
    when 'list'     then  list_subcommand(:bolts, argv)
    when 'create'   then  create_bolt(argv.shift, argv)
    when 'alias'    then  alias_bolt(argv[0], argv[1])
    when 'delete'   then  delete_bolt(argv[0])
    when 'show'     then  show_bolt(argv[0])
    when 'global'   then  globalize_bolts(argv.shift, argv)
    when 'generate' then  generate_bolt(argv)
    else puts "Invalid subcommand '#{subcommand}'", command_usage
    end
  end

  def generate_bolt(argv)
    args, options = parse_args argv
    Lightning::Generator.run(args[0], :once=>args[1], :test=>options[:test] || options[:t])
  end

  def create_bolt(bolt, globs)
    config.bolts[bolt] = Lightning::Config.bolt(globs)
    save_and_say "Created bolt '#{bolt}'"
  end

  def alias_bolt(bolt, bolt_alias)
    if_bolt_found(bolt) do |bolt|
      config.bolts[bolt]['alias'] = bolt_alias
      save_and_say "Aliased bolt '#{bolt}' to '#{bolt_alias}'"
    end
  end

  def delete_bolt(bolt)
    if_bolt_found(bolt) do |bolt|
      config.bolts.delete(bolt)
      save_and_say "Deleted bolt '#{bolt}' and its functions"
    end
  end

  def show_bolt(bolt)
    if_bolt_found(bolt) {|b| puts config.bolts[b].to_yaml.sub("--- \n", '') }
  end

  def globalize_bolts(boolean, arr)
    return puts("First argument must be 'on' or 'off'") unless %w{on off}.include?(boolean)
    if boolean == 'on'
      valid = arr.select {|b| if_bolt_found(b) {|bolt| config.bolts[bolt]['global'] = true } }
      save_and_say "Global on for bolts #{valid.join(', ')}" unless valid.empty?
    else
      valid = arr.select {|b| if_bolt_found(b) {|bolt| config.bolts[bolt].delete('global') ; true } }
      save_and_say "Global off for bolts #{valid.join(', ')}" unless valid.empty?
    end
  end
end