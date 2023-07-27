# tmux keybindings


Leader: `<ctrl><space>`


```
bind-key    -T copy-mode    C-Space              send-keys -X begin-selection
bind-key    -T copy-mode    C-a                  send-keys -X start-of-line
bind-key    -T copy-mode    C-b                  send-keys -X cursor-left
bind-key    -T copy-mode    C-c                  send-keys -X cancel
bind-key    -T copy-mode    C-e                  send-keys -X end-of-line
bind-key    -T copy-mode    C-f                  send-keys -X cursor-right
bind-key    -T copy-mode    C-g                  send-keys -X clear-selection
bind-key    -T copy-mode    C-k                  send-keys -X copy-pipe-end-of-line-and-cancel
bind-key    -T copy-mode    C-n                  send-keys -X cursor-down
bind-key    -T copy-mode    C-p                  send-keys -X cursor-up
bind-key    -T copy-mode    C-r                  command-prompt -i -I "#{pane_search_string}" -T search -p "(search up)" { send-keys -X search-backward-incremental "%%" }
bind-key    -T copy-mode    C-s                  command-prompt -i -I "#{pane_search_string}" -T search -p "(search down)" { send-keys -X search-forward-incremental "%%" }
bind-key    -T copy-mode    C-v                  send-keys -X page-down
bind-key    -T copy-mode    C-w                  send-keys -X copy-pipe-and-cancel
bind-key    -T copy-mode    Escape               send-keys -X cancel
bind-key    -T copy-mode    Space                send-keys -X page-down
bind-key    -T copy-mode    !                    send-keys -X copy-pipe-and-cancel "tr -d '
' | pbcopy"
bind-key    -T copy-mode    ,                    send-keys -X jump-reverse
bind-key    -T copy-mode    \;                   send-keys -X jump-again
bind-key    -T copy-mode    F                    command-prompt -1 -p "(jump backward)" { send-keys -X jump-backward "%%" }
bind-key    -T copy-mode    N                    send-keys -X search-reverse
bind-key    -T copy-mode    P                    send-keys -X toggle-position
bind-key    -T copy-mode    R                    send-keys -X rectangle-toggle
bind-key    -T copy-mode    T                    command-prompt -1 -p "(jump to backward)" { send-keys -X jump-to-backward "%%" }
bind-key    -T copy-mode    X                    send-keys -X set-mark
bind-key    -T copy-mode    Y                    send-keys -X copy-pipe-and-cancel "tmux paste-buffer -p"
bind-key    -T copy-mode    f                    command-prompt -1 -p "(jump forward)" { send-keys -X jump-forward "%%" }
bind-key    -T copy-mode    g                    command-prompt -p "(goto line)" { send-keys -X goto-line "%%" }
bind-key    -T copy-mode    n                    send-keys -X search-again
bind-key    -T copy-mode    q                    send-keys -X cancel
bind-key    -T copy-mode    r                    send-keys -X refresh-from-pane
bind-key    -T copy-mode    t                    command-prompt -1 -p "(jump to forward)" { send-keys -X jump-to-forward "%%" }
bind-key    -T copy-mode    y                    send-keys -X copy-pipe-and-cancel pbcopy
bind-key    -T copy-mode    MouseDown1Pane       select-pane
bind-key    -T copy-mode    MouseDrag1Pane       select-pane \; send-keys -X begin-selection
bind-key    -T copy-mode    MouseDragEnd1Pane    send-keys -X copy-pipe-and-cancel pbcopy
bind-key    -T copy-mode    WheelUpPane          select-pane \; send-keys -X -N 5 scroll-up
bind-key    -T copy-mode    WheelDownPane        select-pane \; send-keys -X -N 5 scroll-down
bind-key    -T copy-mode    DoubleClick1Pane     select-pane \; send-keys -X select-word \; run-shell -d 0.3 \; send-keys -X copy-pipe-and-cancel
bind-key    -T copy-mode    TripleClick1Pane     select-pane \; send-keys -X select-line \; run-shell -d 0.3 \; send-keys -X copy-pipe-and-cancel
bind-key    -T copy-mode    Home                 send-keys -X start-of-line
bind-key    -T copy-mode    End                  send-keys -X end-of-line
bind-key    -T copy-mode    NPage                send-keys -X page-down
bind-key    -T copy-mode    PPage                send-keys -X page-up
bind-key    -T copy-mode    Up                   send-keys -X cursor-up
bind-key    -T copy-mode    Down                 send-keys -X cursor-down
bind-key    -T copy-mode    Left                 send-keys -X cursor-left
bind-key    -T copy-mode    Right                send-keys -X cursor-right
bind-key    -T copy-mode    M-C-b                send-keys -X previous-matching-bracket
bind-key    -T copy-mode    M-C-f                send-keys -X next-matching-bracket
bind-key    -T copy-mode    M-1                  command-prompt -N -I 1 -p (repeat) { send-keys -N "%%" }
bind-key    -T copy-mode    M-2                  command-prompt -N -I 2 -p (repeat) { send-keys -N "%%" }
bind-key    -T copy-mode    M-3                  command-prompt -N -I 3 -p (repeat) { send-keys -N "%%" }
bind-key    -T copy-mode    M-4                  command-prompt -N -I 4 -p (repeat) { send-keys -N "%%" }
bind-key    -T copy-mode    M-5                  command-prompt -N -I 5 -p (repeat) { send-keys -N "%%" }
bind-key    -T copy-mode    M-6                  command-prompt -N -I 6 -p (repeat) { send-keys -N "%%" }
bind-key    -T copy-mode    M-7                  command-prompt -N -I 7 -p (repeat) { send-keys -N "%%" }
bind-key    -T copy-mode    M-8                  command-prompt -N -I 8 -p (repeat) { send-keys -N "%%" }
bind-key    -T copy-mode    M-9                  command-prompt -N -I 9 -p (repeat) { send-keys -N "%%" }
bind-key    -T copy-mode    M-<                  send-keys -X history-top
bind-key    -T copy-mode    M->                  send-keys -X history-bottom
bind-key    -T copy-mode    M-R                  send-keys -X top-line
bind-key    -T copy-mode    M-b                  send-keys -X previous-word
bind-key    -T copy-mode    M-f                  send-keys -X next-word-end
bind-key    -T copy-mode    M-m                  send-keys -X back-to-indentation
bind-key    -T copy-mode    M-r                  send-keys -X middle-line
bind-key    -T copy-mode    M-v                  send-keys -X page-up
bind-key    -T copy-mode    M-w                  send-keys -X copy-pipe-and-cancel
bind-key    -T copy-mode    M-x                  send-keys -X jump-to-mark
bind-key    -T copy-mode    M-y                  send-keys -X copy-pipe-and-cancel "pbcopy; tmux paste-buffer -p"
bind-key    -T copy-mode    "M-{"                send-keys -X previous-paragraph
bind-key    -T copy-mode    "M-}"                send-keys -X next-paragraph
bind-key    -T copy-mode    M-Up                 send-keys -X halfpage-up
bind-key    -T copy-mode    M-Down               send-keys -X halfpage-down
bind-key    -T copy-mode    C-Up                 send-keys -X scroll-up
bind-key    -T copy-mode    C-Down               send-keys -X scroll-down
bind-key    -T copy-mode-vi C-b                  send-keys -X page-up
bind-key    -T copy-mode-vi C-c                  send-keys -X cancel
bind-key    -T copy-mode-vi C-d                  send-keys -X halfpage-down
bind-key    -T copy-mode-vi C-e                  send-keys -X scroll-down
bind-key    -T copy-mode-vi C-f                  send-keys -X page-down
bind-key    -T copy-mode-vi C-h                  select-pane -L
bind-key    -T copy-mode-vi C-j                  select-pane -D
bind-key    -T copy-mode-vi C-k                  select-pane -U
bind-key    -T copy-mode-vi C-l                  select-pane -R
bind-key    -T copy-mode-vi Enter                send-keys -X copy-pipe-and-cancel
bind-key    -T copy-mode-vi C-u                  send-keys -X halfpage-up
bind-key    -T copy-mode-vi C-v                  send-keys -X rectangle-toggle
bind-key    -T copy-mode-vi C-y                  send-keys -X scroll-up
bind-key    -T copy-mode-vi Escape               send-keys -X clear-selection
bind-key    -T copy-mode-vi C-\                 select-pane -l
bind-key    -T copy-mode-vi Space                send-keys -X begin-selection
bind-key    -T copy-mode-vi !                    send-keys -X copy-pipe-and-cancel "tr -d '
' | pbcopy"
bind-key    -T copy-mode-vi \#                   send-keys -FX search-backward "#{copy_cursor_word}"
bind-key    -T copy-mode-vi \$                   send-keys -X end-of-line
bind-key    -T copy-mode-vi \%                   send-keys -X next-matching-bracket
bind-key    -T copy-mode-vi *                    send-keys -FX search-forward "#{copy_cursor_word}"
bind-key    -T copy-mode-vi ,                    send-keys -X jump-reverse
bind-key    -T copy-mode-vi /                    command-prompt -T search -p "(search down)" { send-keys -X search-forward "%%" }
bind-key    -T copy-mode-vi 0                    send-keys -X start-of-line
bind-key    -T copy-mode-vi 1                    command-prompt -N -I 1 -p (repeat) { send-keys -N "%%" }
bind-key    -T copy-mode-vi 2                    command-prompt -N -I 2 -p (repeat) { send-keys -N "%%" }
bind-key    -T copy-mode-vi 3                    command-prompt -N -I 3 -p (repeat) { send-keys -N "%%" }
bind-key    -T copy-mode-vi 4                    command-prompt -N -I 4 -p (repeat) { send-keys -N "%%" }
bind-key    -T copy-mode-vi 5                    command-prompt -N -I 5 -p (repeat) { send-keys -N "%%" }
bind-key    -T copy-mode-vi 6                    command-prompt -N -I 6 -p (repeat) { send-keys -N "%%" }
bind-key    -T copy-mode-vi 7                    command-prompt -N -I 7 -p (repeat) { send-keys -N "%%" }
bind-key    -T copy-mode-vi 8                    command-prompt -N -I 8 -p (repeat) { send-keys -N "%%" }
bind-key    -T copy-mode-vi 9                    command-prompt -N -I 9 -p (repeat) { send-keys -N "%%" }
bind-key    -T copy-mode-vi :                    command-prompt -p "(goto line)" { send-keys -X goto-line "%%" }
bind-key    -T copy-mode-vi \;                   send-keys -X jump-again
bind-key    -T copy-mode-vi ?                    command-prompt -T search -p "(search up)" { send-keys -X search-backward "%%" }
bind-key    -T copy-mode-vi A                    send-keys -X append-selection-and-cancel
bind-key    -T copy-mode-vi B                    send-keys -X previous-space
bind-key    -T copy-mode-vi D                    send-keys -X copy-pipe-end-of-line-and-cancel
bind-key    -T copy-mode-vi E                    send-keys -X next-space-end
bind-key    -T copy-mode-vi F                    command-prompt -1 -p "(jump backward)" { send-keys -X jump-backward "%%" }
bind-key    -T copy-mode-vi G                    send-keys -X history-bottom
bind-key    -T copy-mode-vi H                    send-keys -X top-line
bind-key    -T copy-mode-vi J                    send-keys -X scroll-down
bind-key    -T copy-mode-vi K                    send-keys -X scroll-up
bind-key    -T copy-mode-vi L                    send-keys -X bottom-line
bind-key    -T copy-mode-vi M                    send-keys -X middle-line
bind-key    -T copy-mode-vi N                    send-keys -X search-reverse
bind-key    -T copy-mode-vi P                    send-keys -X toggle-position
bind-key    -T copy-mode-vi T                    command-prompt -1 -p "(jump to backward)" { send-keys -X jump-to-backward "%%" }
bind-key    -T copy-mode-vi V                    send-keys -X select-line
bind-key    -T copy-mode-vi W                    send-keys -X next-space
bind-key    -T copy-mode-vi X                    send-keys -X set-mark
bind-key    -T copy-mode-vi Y                    send-keys -X copy-pipe-and-cancel "tmux paste-buffer -p"
bind-key    -T copy-mode-vi ^                    send-keys -X back-to-indentation
bind-key    -T copy-mode-vi b                    send-keys -X previous-word
bind-key    -T copy-mode-vi e                    send-keys -X next-word-end
bind-key    -T copy-mode-vi f                    command-prompt -1 -p "(jump forward)" { send-keys -X jump-forward "%%" }
bind-key    -T copy-mode-vi g                    send-keys -X history-top
bind-key    -T copy-mode-vi h                    send-keys -X cursor-left
bind-key    -T copy-mode-vi j                    send-keys -X cursor-down
bind-key    -T copy-mode-vi k                    send-keys -X cursor-up
bind-key    -T copy-mode-vi l                    send-keys -X cursor-right
bind-key    -T copy-mode-vi n                    send-keys -X search-again
bind-key    -T copy-mode-vi o                    send-keys -X other-end
bind-key    -T copy-mode-vi q                    send-keys -X cancel
bind-key    -T copy-mode-vi r                    send-keys -X refresh-from-pane
bind-key    -T copy-mode-vi t                    command-prompt -1 -p "(jump to forward)" { send-keys -X jump-to-forward "%%" }
bind-key    -T copy-mode-vi v                    send-keys -X begin-selection
bind-key    -T copy-mode-vi w                    send-keys -X next-word
bind-key    -T copy-mode-vi y                    send-keys -X copy-pipe-and-cancel pbcopy
bind-key    -T copy-mode-vi \{                   send-keys -X previous-paragraph
bind-key    -T copy-mode-vi \}                   send-keys -X next-paragraph
bind-key    -T copy-mode-vi MouseDown1Pane       select-pane
bind-key    -T copy-mode-vi MouseDrag1Pane       select-pane \; send-keys -X begin-selection
bind-key    -T copy-mode-vi MouseDragEnd1Pane    send-keys -X copy-pipe-and-cancel pbcopy
bind-key    -T copy-mode-vi WheelUpPane          select-pane \; send-keys -X -N 5 scroll-up
bind-key    -T copy-mode-vi WheelDownPane        select-pane \; send-keys -X -N 5 scroll-down
bind-key    -T copy-mode-vi DoubleClick1Pane     select-pane \; send-keys -X select-word \; run-shell -d 0.3 \; send-keys -X copy-pipe-and-cancel
bind-key    -T copy-mode-vi TripleClick1Pane     select-pane \; send-keys -X select-line \; run-shell -d 0.3 \; send-keys -X copy-pipe-and-cancel
bind-key    -T copy-mode-vi BSpace               send-keys -X cursor-left
bind-key    -T copy-mode-vi NPage                send-keys -X page-down
bind-key    -T copy-mode-vi PPage                send-keys -X page-up
bind-key    -T copy-mode-vi Up                   send-keys -X cursor-up
bind-key    -T copy-mode-vi Down                 send-keys -X cursor-down
bind-key    -T copy-mode-vi Left                 send-keys -X cursor-left
bind-key    -T copy-mode-vi Right                send-keys -X cursor-right
bind-key    -T copy-mode-vi M-x                  send-keys -X jump-to-mark
bind-key    -T copy-mode-vi M-y                  send-keys -X copy-pipe-and-cancel "pbcopy; tmux paste-buffer -p"
bind-key    -T copy-mode-vi C-Up                 send-keys -X scroll-up
bind-key    -T copy-mode-vi C-Down               send-keys -X scroll-down
bind-key    -T join-pane    \"                   run-shell "'/Users/ivuorinen/.config/tmux/plugins/tmux-sessionist/scripts/join_pane.sh' 'join-pane' '-b' '-v'"
bind-key    -T join-pane    \%                   run-shell "'/Users/ivuorinen/.config/tmux/plugins/tmux-sessionist/scripts/join_pane.sh' 'join-pane' '-b' '-h'"
bind-key    -T join-pane    -                    run-shell "'/Users/ivuorinen/.config/tmux/plugins/tmux-sessionist/scripts/join_pane.sh' 'join-pane' '-b' '-v'"
bind-key    -T join-pane    @                    run-shell "'/Users/ivuorinen/.config/tmux/plugins/tmux-sessionist/scripts/join_pane.sh' 'join-pane' '-b' '-b'"
bind-key    -T join-pane    f                    run-shell "'/Users/ivuorinen/.config/tmux/plugins/tmux-sessionist/scripts/join_pane.sh' 'join-pane' '-b' '-b'"
bind-key    -T join-pane    h                    run-shell "'/Users/ivuorinen/.config/tmux/plugins/tmux-sessionist/scripts/join_pane.sh' 'join-pane' '-b' '-h'"
bind-key    -T join-pane    v                    run-shell "'/Users/ivuorinen/.config/tmux/plugins/tmux-sessionist/scripts/join_pane.sh' 'join-pane' '-b' '-v'"
bind-key    -T join-pane    |                    run-shell "'/Users/ivuorinen/.config/tmux/plugins/tmux-sessionist/scripts/join_pane.sh' 'join-pane' '-b' '-h'"
bind-key    -T prefix       C-Space              run-shell "/Users/ivuorinen/.config/tmux/plugins/tmux-sessionist/scripts/promote_window.sh '#{session_name}' '#{window_id}' '#{window_name}' '#{pane_current_path}'"
bind-key    -T prefix       Enter                run-shell -b "/Users/ivuorinen/.config/tmux/plugins/tmux-notify/scripts/notify.sh false true"
bind-key    -T prefix       C-n                  next-window
bind-key    -T prefix       C-o                  rotate-window
bind-key    -T prefix       C-p                  previous-window
bind-key    -T prefix       C-r                  run-shell /Users/ivuorinen/.config/tmux/plugins/tmux-resurrect/scripts/restore.sh
bind-key    -T prefix       C-s                  run-shell /Users/ivuorinen/.config/tmux/plugins/tmux-resurrect/scripts/save.sh
bind-key    -T prefix       C-z                  suspend-client
bind-key    -T prefix       Escape               copy-mode
bind-key    -T prefix       Space                next-layout
bind-key    -T prefix       !                    split-window -h -c "#{pane_current_path}"
bind-key    -T prefix       \"                   split-window -v -c "#{pane_current_path}"
bind-key    -T prefix       \#                   list-buffers
bind-key    -T prefix       \$                   command-prompt -I "#S" { rename-session "%%" }
bind-key    -T prefix       \%                   split-window -h -c "#{pane_current_path}"
bind-key    -T prefix       &                    confirm-before -p "kill-window #W? (y/n)" kill-window
bind-key    -T prefix       \'                   command-prompt -T window-target -p index { select-window -t ":%%" }
bind-key    -T prefix       (                    switch-client -p
bind-key    -T prefix       )                    switch-client -n
bind-key    -T prefix       ,                    command-prompt -I "#W" { rename-window "%%" }
bind-key    -T prefix       -                    delete-buffer
bind-key    -T prefix       .                    command-prompt -T target { move-window -t "%%" }
bind-key    -T prefix       /                    command-prompt -k -p key { list-keys -1N "%%" }
bind-key    -T prefix       0                    select-window -t :=0
bind-key    -T prefix       1                    select-window -t :=1
bind-key    -T prefix       2                    select-window -t :=2
bind-key    -T prefix       3                    select-window -t :=3
bind-key    -T prefix       4                    select-window -t :=4
bind-key    -T prefix       5                    select-window -t :=5
bind-key    -T prefix       6                    select-window -t :=6
bind-key    -T prefix       7                    select-window -t :=7
bind-key    -T prefix       8                    select-window -t :=8
bind-key    -T prefix       9                    select-window -t :=9
bind-key    -T prefix       :                    command-prompt
bind-key    -T prefix       \;                   last-pane
bind-key    -T prefix       <                    display-menu -T "#[align=centre]#{window_index}:#{window_name}" -x W -y W "#{?#{>:#{session_windows},1},,-}Swap Left" l { swap-window -t :-1 } "#{?#{>:#{session_windows},1},,-}Swap Right" r { swap-window -t :+1 } "#{?pane_marked_set,,-}Swap Marked" s { swap-window } '' Kill X { kill-window } Respawn R { respawn-window -k } "#{?pane_marked,Unmark,Mark}" m { select-pane -m } Rename n { command-prompt -F -I "#W" { rename-window -t "#{window_id}" "%%" } } '' "New After" w { new-window -a } "New At End" W { new-window }
bind-key    -T prefix       =                    choose-buffer -Z
bind-key    -T prefix       >                    display-menu -T "#[align=centre]#{pane_index} (#{pane_id})" -x P -y P "#{?#{m/r:(copy|view)-mode,#{pane_mode}},Go To Top,}" < { send-keys -X history-top } "#{?#{m/r:(copy|view)-mode,#{pane_mode}},Go To Bottom,}" > { send-keys -X history-bottom } '' "#{?mouse_word,Search For #[underscore]#{=/9/...:mouse_word},}" C-r { if-shell -F "#{?#{m/r:(copy|view)-mode,#{pane_mode}},0,1}" "copy-mode -t=" ; send-keys -X -t = search-backward "#{q:mouse_word}" } "#{?mouse_word,Type #[underscore]#{=/9/...:mouse_word},}" C-y { copy-mode -q ; send-keys -l "#{q:mouse_word}" } "#{?mouse_word,Copy #[underscore]#{=/9/...:mouse_word},}" c { copy-mode -q ; set-buffer "#{q:mouse_word}" } "#{?mouse_line,Copy Line,}" l { copy-mode -q ; set-buffer "#{q:mouse_line}" } '' "Horizontal Split" h { split-window -h } "Vertical Split" v { split-window -v } '' "#{?#{>:#{window_panes},1},,-}Swap Up" u { swap-pane -U } "#{?#{>:#{window_panes},1},,-}Swap Down" d { swap-pane -D } "#{?pane_marked_set,,-}Swap Marked" s { swap-pane } '' Kill X { kill-pane } Respawn R { respawn-pane -k } "#{?pane_marked,Unmark,Mark}" m { select-pane -m } "#{?#{>:#{window_panes},1},,-}#{?window_zoomed_flag,Unzoom,Zoom}" z { resize-pane -Z }
bind-key    -T prefix       ?                    list-keys -N
bind-key    -T prefix       @                    run-shell "/Users/ivuorinen/.config/tmux/plugins/tmux-sessionist/scripts/promote_pane.sh '#{session_name}' '#{pane_id}' '#{pane_current_path}'"
bind-key    -T prefix       C                    run-shell /Users/ivuorinen/.config/tmux/plugins/tmux-sessionist/scripts/new_session_prompt.sh
bind-key    -T prefix       D                    choose-client -Z
bind-key    -T prefix       E                    select-layout -E
bind-key    -T prefix       I                    run-shell /Users/ivuorinen/.config/tmux/plugins/tpm/bindings/install_plugins
bind-key    -T prefix       L                    switch-client -l
bind-key    -T prefix       M                    run-shell -b /Users/ivuorinen/.config/tmux/plugins/tmux-notify/scripts/cancel.sh
bind-key    -T prefix       N                    new-window
bind-key    -T prefix       R                    run-shell " 			tmux source-file /Users/ivuorinen/.config/tmux/tmux.conf > /dev/null; 			tmux display-message 'Sourced /Users/ivuorinen/.config/tmux/tmux.conf!'"
bind-key    -T prefix       S                    switch-client -l
bind-key    -T prefix       U                    run-shell /Users/ivuorinen/.config/tmux/plugins/tpm/bindings/update_plugins
bind-key    -T prefix       X                    run-shell "/Users/ivuorinen/.config/tmux/plugins/tmux-sessionist/scripts/kill_session_prompt.sh '#{session_name}' '#{session_id}'"
bind-key    -T prefix       Y                    run-shell -b /Users/ivuorinen/.config/tmux/plugins/tmux-yank/scripts/copy_pane_pwd.sh
bind-key    -T prefix       ]                    paste-buffer -p
bind-key    -T prefix       c                    new-window
bind-key    -T prefix       d                    detach-client
bind-key    -T prefix       f                    command-prompt { find-window -Z "%%" }
bind-key    -T prefix       g                    run-shell /Users/ivuorinen/.config/tmux/plugins/tmux-sessionist/scripts/goto_session.sh
bind-key    -T prefix       h                    select-pane -L
bind-key    -T prefix       i                    display-message
bind-key    -T prefix       j                    select-pane -D
bind-key    -T prefix       k                    select-pane -U
bind-key    -T prefix       l                    run-shell -b /Users/ivuorinen/.config/tmux/plugins/tmux-fzf/main.sh
bind-key    -T prefix       m                    run-shell /Users/ivuorinen/.config/tmux/plugins/tmux-menus/items/main.sh
bind-key    -T prefix       n                    next-window
bind-key    -T prefix       o                    select-pane -t :.+
bind-key    -T prefix       p                    paste-buffer
bind-key    -T prefix       q                    display-panes
bind-key    -T prefix       r                    source-file /Users/ivuorinen/.dotfiles/config/tmux/tmux.conf \; display-message "tmux cfg reloaded!"
bind-key    -T prefix       s                    choose-tree -Zs
bind-key    -T prefix       t                    run-shell "/Users/ivuorinen/.config/tmux/plugins/tmux-sessionist/scripts/join_pane.sh 'join-pane' '-b'"
bind-key    -T prefix       w                    choose-tree -Zw
bind-key    -T prefix       x                    run-shell "tmux split-window -l 10 \"/Users/ivuorinen/.config/tmux/plugins/tmux-1password/scripts/main.sh '#{pane_id}'\""
bind-key    -T prefix       y                    run-shell -b /Users/ivuorinen/.config/tmux/plugins/tmux-yank/scripts/copy_line.sh
bind-key    -T prefix       z                    resize-pane -Z
bind-key    -T prefix       \{                   swap-pane -U
bind-key    -T prefix       \}                   swap-pane -D
bind-key    -T prefix       \~                   show-messages
bind-key -r -T prefix       DC                   refresh-client -c
bind-key    -T prefix       PPage                copy-mode -u
bind-key -r -T prefix       Up                   select-pane -U
bind-key -r -T prefix       Down                 select-pane -D
bind-key -r -T prefix       Left                 select-pane -L
bind-key -r -T prefix       Right                select-pane -R
bind-key    -T prefix       M-Enter              run-shell -b "/Users/ivuorinen/.config/tmux/plugins/tmux-notify/scripts/notify.sh true true"
bind-key    -T prefix       M-1                  select-layout even-horizontal
bind-key    -T prefix       M-2                  select-layout even-vertical
bind-key    -T prefix       M-3                  select-layout main-horizontal
bind-key    -T prefix       M-4                  select-layout main-vertical
bind-key    -T prefix       M-5                  select-layout tiled
bind-key    -T prefix       M-m                  run-shell -b "/Users/ivuorinen/.config/tmux/plugins/tmux-notify/scripts/notify.sh true"
bind-key    -T prefix       M-n                  next-window -a
bind-key    -T prefix       M-o                  rotate-window -D
bind-key    -T prefix       M-p                  previous-window -a
bind-key    -T prefix       M-u                  run-shell /Users/ivuorinen/.config/tmux/plugins/tpm/bindings/clean_plugins
bind-key -r -T prefix       M-Up                 resize-pane -U 5
bind-key -r -T prefix       M-Down               resize-pane -D 5
bind-key -r -T prefix       M-Left               resize-pane -L 5
bind-key -r -T prefix       M-Right              resize-pane -R 5
bind-key -r -T prefix       C-Up                 resize-pane -U
bind-key -r -T prefix       C-Down               resize-pane -D
bind-key -r -T prefix       C-Left               resize-pane -L
bind-key -r -T prefix       C-Right              resize-pane -R
bind-key -r -T prefix       S-Up                 refresh-client -U 10
bind-key -r -T prefix       S-Down               refresh-client -D 10
bind-key -r -T prefix       S-Left               refresh-client -L 10
bind-key -r -T prefix       S-Right              refresh-client -R 10
bind-key    -T root         C-h                  if-shell "ps -o state= -o comm= -t '#{pane_tty}'     | grep -iqE '^[^TXZ ]+ +(\S+\/)?g?(view|l?n?vim?x?)(diff)?$'" "send-keys C-h" "select-pane -L"
bind-key    -T root         C-j                  if-shell "ps -o state= -o comm= -t '#{pane_tty}'     | grep -iqE '^[^TXZ ]+ +(\S+\/)?g?(view|l?n?vim?x?)(diff)?$'" "send-keys C-j" "select-pane -D"
bind-key    -T root         C-k                  if-shell "ps -o state= -o comm= -t '#{pane_tty}'     | grep -iqE '^[^TXZ ]+ +(\S+\/)?g?(view|l?n?vim?x?)(diff)?$'" "send-keys C-k" "select-pane -U"
bind-key    -T root         C-l                  if-shell "ps -o state= -o comm= -t '#{pane_tty}'     | grep -iqE '^[^TXZ ]+ +(\S+\/)?g?(view|l?n?vim?x?)(diff)?$'" "send-keys C-l" "select-pane -R"
bind-key    -T root         C-\                 if-shell "ps -o state= -o comm= -t '#{pane_tty}'     | grep -iqE '^[^TXZ ]+ +(S+/)?g?(view|l?n?vim?x?)(diff)?$'" "send-keys C-\\" "select-pane -l"
bind-key    -T root         MouseDown1Pane       select-pane -t = \; send-keys -M
bind-key    -T root         MouseDown1Status     select-window -t =
bind-key    -T root         MouseDown2Pane       select-pane -t = \; if-shell -F "#{||:#{pane_in_mode},#{mouse_any_flag}}" { send-keys -M } { paste-buffer -p }
bind-key    -T root         MouseDown3Pane       if-shell -F -t = "#{||:#{mouse_any_flag},#{&&:#{pane_in_mode},#{?#{m/r:(copy|view)-mode,#{pane_mode}},0,1}}}" { select-pane -t = ; send-keys -M } { display-menu -T "#[align=centre]#{pane_index} (#{pane_id})" -t = -x M -y M "#{?#{m/r:(copy|view)-mode,#{pane_mode}},Go To Top,}" < { send-keys -X history-top } "#{?#{m/r:(copy|view)-mode,#{pane_mode}},Go To Bottom,}" > { send-keys -X history-bottom } '' "#{?mouse_word,Search For #[underscore]#{=/9/...:mouse_word},}" C-r { if-shell -F "#{?#{m/r:(copy|view)-mode,#{pane_mode}},0,1}" "copy-mode -t=" ; send-keys -X -t = search-backward "#{q:mouse_word}" } "#{?mouse_word,Type #[underscore]#{=/9/...:mouse_word},}" C-y { copy-mode -q ; send-keys -l "#{q:mouse_word}" } "#{?mouse_word,Copy #[underscore]#{=/9/...:mouse_word},}" c { copy-mode -q ; set-buffer "#{q:mouse_word}" } "#{?mouse_line,Copy Line,}" l { copy-mode -q ; set-buffer "#{q:mouse_line}" } '' "Horizontal Split" h { split-window -h } "Vertical Split" v { split-window -v } '' "#{?#{>:#{window_panes},1},,-}Swap Up" u { swap-pane -U } "#{?#{>:#{window_panes},1},,-}Swap Down" d { swap-pane -D } "#{?pane_marked_set,,-}Swap Marked" s { swap-pane } '' Kill X { kill-pane } Respawn R { respawn-pane -k } "#{?pane_marked,Unmark,Mark}" m { select-pane -m } "#{?#{>:#{window_panes},1},,-}#{?window_zoomed_flag,Unzoom,Zoom}" z { resize-pane -Z } }
bind-key    -T root         MouseDown3Status     display-menu -T "#[align=centre]#{window_index}:#{window_name}" -t = -x W -y W "#{?#{>:#{session_windows},1},,-}Swap Left" l { swap-window -t :-1 } "#{?#{>:#{session_windows},1},,-}Swap Right" r { swap-window -t :+1 } "#{?pane_marked_set,,-}Swap Marked" s { swap-window } '' Kill X { kill-window } Respawn R { respawn-window -k } "#{?pane_marked,Unmark,Mark}" m { select-pane -m } Rename n { command-prompt -F -I "#W" { rename-window -t "#{window_id}" "%%" } } '' "New After" w { new-window -a } "New At End" W { new-window }
bind-key    -T root         MouseDown3StatusLeft display-menu -T "#[align=centre]#{session_name}" -t = -x M -y W Next n { switch-client -n } Previous p { switch-client -p } '' Renumber N { move-window -r } Rename n { command-prompt -I "#S" { rename-session "%%" } } '' "New Session" s { new-session } "New Window" w { new-window }
bind-key    -T root         MouseDrag1Pane       if-shell -F "#{||:#{pane_in_mode},#{mouse_any_flag}}" { send-keys -M } { copy-mode -M }
bind-key    -T root         MouseDrag1Border     resize-pane -M
bind-key    -T root         WheelUpPane          if-shell -F "#{||:#{pane_in_mode},#{mouse_any_flag}}" { send-keys -M } { copy-mode -e }
bind-key    -T root         WheelUpStatus        previous-window
bind-key    -T root         WheelDownStatus      next-window
bind-key    -T root         DoubleClick1Pane     select-pane -t = \; if-shell -F "#{||:#{pane_in_mode},#{mouse_any_flag}}" { send-keys -M } { copy-mode -H ; send-keys -X select-word ; run-shell -d 0.3 ; send-keys -X copy-pipe-and-cancel }
bind-key    -T root         TripleClick1Pane     select-pane -t = \; if-shell -F "#{||:#{pane_in_mode},#{mouse_any_flag}}" { send-keys -M } { copy-mode -H ; send-keys -X select-line ; run-shell -d 0.3 ; send-keys -X copy-pipe-and-cancel }
bind-key    -T root         F12                  run-shell "/Users/ivuorinen/.config/tmux/plugins/tmux-suspend/scripts/suspend.sh \"\" \"   @mode_indicator_custom_prompt:: ---- ,   @mode_indicator_custom_mode_style::bg=brightblack\,fg=black, \""
bind-key    -T root         M-H                  previous-window
bind-key    -T root         M-L                  next-window
bind-key    -T root         M-MouseDown3Pane     display-menu -T "#[align=centre]#{pane_index} (#{pane_id})" -t = -x M -y M "#{?#{m/r:(copy|view)-mode,#{pane_mode}},Go To Top,}" < { send-keys -X history-top } "#{?#{m/r:(copy|view)-mode,#{pane_mode}},Go To Bottom,}" > { send-keys -X history-bottom } '' "#{?mouse_word,Search For #[underscore]#{=/9/...:mouse_word},}" C-r { if-shell -F "#{?#{m/r:(copy|view)-mode,#{pane_mode}},0,1}" "copy-mode -t=" ; send-keys -X -t = search-backward "#{q:mouse_word}" } "#{?mouse_word,Type #[underscore]#{=/9/...:mouse_word},}" C-y { copy-mode -q ; send-keys -l "#{q:mouse_word}" } "#{?mouse_word,Copy #[underscore]#{=/9/...:mouse_word},}" c { copy-mode -q ; set-buffer "#{q:mouse_word}" } "#{?mouse_line,Copy Line,}" l { copy-mode -q ; set-buffer "#{q:mouse_line}" } '' "Horizontal Split" h { split-window -h } "Vertical Split" v { split-window -v } '' "#{?#{>:#{window_panes},1},,-}Swap Up" u { swap-pane -U } "#{?#{>:#{window_panes},1},,-}Swap Down" d { swap-pane -D } "#{?pane_marked_set,,-}Swap Marked" s { swap-pane } '' Kill X { kill-pane } Respawn R { respawn-pane -k } "#{?pane_marked,Unmark,Mark}" m { select-pane -m } "#{?#{>:#{window_panes},1},,-}#{?window_zoomed_flag,Unzoom,Zoom}" z { resize-pane -Z }
bind-key    -T root         M-Up                 select-pane -U
bind-key    -T root         M-Down               select-pane -D
bind-key    -T root         M-Left               select-pane -L
bind-key    -T root         M-Right              select-pane -R
bind-key    -T root         S-Left               previous-window
bind-key    -T root         S-Right              next-window
bind-key    -T suspended    F12                  run-shell "/Users/ivuorinen/.config/tmux/plugins/tmux-suspend/scripts/resume.sh \"\""
```

