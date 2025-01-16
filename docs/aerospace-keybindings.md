# aerospace keybindings

## main

| Key             | Command(s) and actions                        |
|-----------------|-----------------------------------------------|
| alt-a           | mode apps                                     |
| alt-h           | focus left                                    |
| alt-j           | focus down                                    |
| alt-k           | focus up                                      |
| alt-l           | focus right                                   |
| alt-m           | mode move                                     |
| alt-s           | mode service                                  |
| alt-shift-1     | workspace 1                                   |
| alt-shift-2     | workspace 2                                   |
| alt-shift-tab   | workspace-back-and-forth                      |
| ctrl-shift-1    | move-node-to-workspace 1                      |
| ctrl-shift-2    | move-node-to-workspace 2                      |
| ctrl-shift-tab  | move-workspace-to-monitor --wrap-around prev  |

## apps

| Key  | Command(s) and actions                                               |
|------|----------------------------------------------------------------------|
| b    | exec-and-forget  open -a /Applications/Brave Browser.app; mode main  |
| c    | exec-and-forget  open -a /Applications/Ferdium.app; mode main        |
| esc  | reload-config; mode main                                             |
| g    | exec-and-forget  open -a /Applications/Ghostty.app; mode main        |
| o    | exec-and-forget  open -a /Applications/Obsidian.app; mode main       |
| s    | exec-and-forget  open -a /Applications/Slack.app; mode main          |
| t    | exec-and-forget  open -a /Applications/TIDAL.app; mode main          |
| w    | exec-and-forget  open -a /Applications/WezTerm.app; mode main        |

## move

| Key          | Command(s) and actions                           |
|--------------|--------------------------------------------------|
| 1            | move-node-to-workspace 1 --focus-follows-window  |
| 2            | move-node-to-workspace 2 --focus-follows-window  |
| ctrl-h       | resize smart -70                                 |
| ctrl-l       | resize smart +70                                 |
| esc          | reload-config; mode main                         |
| h            | move left                                        |
| j            | move down                                        |
| k            | move up                                          |
| l            | move right                                       |
| r            | flatten-workspace-tree; mode main                |
| shift-h      | join-with left                                   |
| shift-j      | join-with down                                   |
| shift-k      | join-with up                                     |
| shift-l      | join-with right                                  |
| shift-left   | resize smart +70                                 |
| shift-right  | resize smart -70                                 |

## service

| Key        | Command(s) and actions                    |
|------------|-------------------------------------------|
| backspace  | close-all-windows-but-current; mode main  |
| esc        | reload-config; mode main                  |
| f          | layout floating tiling; mode main         |
| r          | flatten-workspace-tree; mode main         |

File generated: 2025-01-15 13:32:41

Config file: [config/aerospace/aerospace.toml](./../config/aerospace/aerospace.toml)
