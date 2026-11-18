function copilot --wraps copilot --description 'Run Copilot with skill directories allowed'
    set -l copilot_home "$HOME/.copilot"
    if set -q COPILOT_HOME; and test -n "$COPILOT_HOME"
        set copilot_home "$COPILOT_HOME"
    end

    # Directories Copilot may use without asking, one path or glob each.
    # Globs expand here; one that matches nothing drops out, and so does a
    # match that is not a directory.
    set -l allowed $HOME/.agents/skills/* $copilot_home/skills/*
    # Nitpicker is granted whatever the list says. --add-dir covers the whole
    # tree, so its commands, scripts and references come with it.
    set -a allowed $HOME/.agents/skills/nitpicker $copilot_home/skills/nitpicker

    set -l add_dir_args
    for match in $allowed
        test -d "$match"; or continue
        # Copilot may see a linked skill by its target path, so grant both.
        for directory in "$match" (path resolve -- "$match")
            contains -- "$directory" $add_dir_args
            or set -a add_dir_args --add-dir "$directory"
        end
    end

    command copilot $add_dir_args $argv
end
