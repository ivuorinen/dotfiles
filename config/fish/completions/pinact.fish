# pinact fish shell completion

function __fish_pinact_no_subcommand --description 'Test if there has been any subcommand yet'
    for i in (commandline -opc)
        if contains -- $i init run migrate token version help-all help h completion
            return 1
        end
    end
    return 0
end

complete -c pinact -n '__fish_pinact_no_subcommand' -f -l log-level -r -d 'log level'
complete -c pinact -n '__fish_pinact_no_subcommand' -f -l config -s c -r -d 'configuration file path'
complete -c pinact -n '__fish_pinact_no_subcommand' -f -l help -s h -d 'show help'
complete -c pinact -n '__fish_pinact_no_subcommand' -f -l version -s v -d 'print the version'
complete -x -c pinact -n '__fish_pinact_no_subcommand' -a 'init' -d 'Create .pinact.yaml if it doesn\'t exist'
complete -c pinact -n '__fish_seen_subcommand_from init' -f -l help -s h -d 'show help'
complete -x -c pinact -n '__fish_seen_subcommand_from init; and not __fish_seen_subcommand_from help h' -a 'help' -d 'Shows a list of commands or help for one command'
complete -x -c pinact -n '__fish_pinact_no_subcommand' -a 'run' -d 'Pin GitHub Actions versions'
complete -c pinact -n '__fish_seen_subcommand_from run' -f -l verify -s v -d 'Verify if pairs of commit SHA and version are correct'
complete -c pinact -n '__fish_seen_subcommand_from run' -f -l check -d 'Exit with a non-zero status code if actions are not pinned. If this is true, files aren\'t updated'
complete -c pinact -n '__fish_seen_subcommand_from run' -f -l update -s u -d 'Update actions to latest versions'
complete -c pinact -n '__fish_seen_subcommand_from run' -f -l review -d 'Create reviews'
complete -c pinact -n '__fish_seen_subcommand_from run' -f -l fix -d 'Fix code. By default, this is true. If -check or -diff is true, this is false by default'
complete -c pinact -n '__fish_seen_subcommand_from run' -f -l diff -d 'Output diff. By default, this is false'
complete -c pinact -n '__fish_seen_subcommand_from run' -f -l repo-owner -r -d 'GitHub repository owner'
complete -c pinact -n '__fish_seen_subcommand_from run' -f -l repo-name -r -d 'GitHub repository name'
complete -c pinact -n '__fish_seen_subcommand_from run' -f -l sha -r -d 'Commit SHA to be reviewed'
complete -c pinact -n '__fish_seen_subcommand_from run' -f -l pr -r -d 'GitHub pull request number'
complete -c pinact -n '__fish_seen_subcommand_from run' -f -l help -s h -d 'show help'
complete -x -c pinact -n '__fish_seen_subcommand_from run; and not __fish_seen_subcommand_from help h' -a 'help' -d 'Shows a list of commands or help for one command'
complete -x -c pinact -n '__fish_pinact_no_subcommand' -a 'migrate' -d 'Migrate .pinact.yaml'
complete -c pinact -n '__fish_seen_subcommand_from migrate' -f -l help -s h -d 'show help'
complete -x -c pinact -n '__fish_seen_subcommand_from migrate; and not __fish_seen_subcommand_from help h' -a 'help' -d 'Shows a list of commands or help for one command'
complete -x -c pinact -n '__fish_pinact_no_subcommand' -a 'token' -d 'Manage GitHub Access token'
complete -c pinact -n '__fish_seen_subcommand_from token' -f -l help -s h -d 'show help'
complete -x -c pinact -n '__fish_seen_subcommand_from token; and not __fish_seen_subcommand_from set remove rm help h' -a 'set' -d 'Set GitHub Access token'
complete -c pinact -n '__fish_seen_subcommand_from token; and __fish_seen_subcommand_from set' -f -l stdin -d 'Read GitHub Access token from stdin'
complete -c pinact -n '__fish_seen_subcommand_from token; and __fish_seen_subcommand_from set' -f -l help -s h -d 'show help'
complete -x -c pinact -n '__fish_seen_subcommand_from token; and __fish_seen_subcommand_from set; and not __fish_seen_subcommand_from help h' -a 'help' -d 'Shows a list of commands or help for one command'
complete -x -c pinact -n '__fish_seen_subcommand_from token; and not __fish_seen_subcommand_from set remove rm help h' -a 'remove' -d 'Remove GitHub Access token'
complete -c pinact -n '__fish_seen_subcommand_from token; and __fish_seen_subcommand_from remove rm' -f -l help -s h -d 'show help'
complete -x -c pinact -n '__fish_seen_subcommand_from token; and __fish_seen_subcommand_from remove rm; and not __fish_seen_subcommand_from help h' -a 'help' -d 'Shows a list of commands or help for one command'
complete -x -c pinact -n '__fish_seen_subcommand_from token; and not __fish_seen_subcommand_from set remove rm help h' -a 'help' -d 'Shows a list of commands or help for one command'
complete -x -c pinact -n '__fish_pinact_no_subcommand' -a 'version' -d 'Show version'
complete -c pinact -n '__fish_seen_subcommand_from version' -f -l json -s j -d 'Output version in JSON format'
complete -c pinact -n '__fish_seen_subcommand_from version' -f -l help -s h -d 'show help'
complete -x -c pinact -n '__fish_seen_subcommand_from version; and not __fish_seen_subcommand_from help h' -a 'help' -d 'Shows a list of commands or help for one command'
complete -c pinact -n '__fish_seen_subcommand_from help-all' -f -l help -s h -d 'show help'
complete -x -c pinact -n '__fish_seen_subcommand_from help-all; and not __fish_seen_subcommand_from help h' -a 'help' -d 'Shows a list of commands or help for one command'
complete -x -c pinact -n '__fish_pinact_no_subcommand' -a 'help' -d 'Shows a list of commands or help for one command'
complete -x -c pinact -n '__fish_pinact_no_subcommand' -a 'completion' -d 'Output shell completion script for bash, zsh, fish, or Powershell'
complete -c pinact -n '__fish_seen_subcommand_from completion' -f -l help -s h -d 'show help'
complete -x -c pinact -n '__fish_seen_subcommand_from completion; and not __fish_seen_subcommand_from help h' -a 'help' -d 'Shows a list of commands or help for one command'
