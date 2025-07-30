#!/bin/bash

SELECTION=$(tmux list-sessions -F \#S | fzf \
    --tmux 80%,90% \
    --no-sort \
    --ansi \
    --border-label ' tmux ' \
    --prompt '> ' \
    --header '^s session ^n new ^d kill' \
    --bind 'tab:down,btab:up' \
    --bind 'ctrl-s:reload(tmux list-sessions -F \#S)+change-preview(tmux capture-pane -ep -t {})' \
    --bind 'ctrl-n:reload(fd -H -d 2 -t d . ~)+change-preview(ls -lha --color {})' \
    --bind 'ctrl-d:execute(tmux kill-session -t {})+reload(tmux list-sessions -F \#S)+change-preview(tmux capture-pane -ep -t {})' \
    --preview-window 'right:60%' \
    --preview 'tmux capture-pane -ep -t {}'
)

if [[ -z ${SELECTION} ]]; then
    exit 0
fi

SESSION_NAME=$(basename ${SELECTION})

tmux has-session -t ${SESSION_NAME} 2>/dev/null

if [[ ! $? == 0 ]]; then
    tmux new-session -d -c ${SELECTION} -s ${SESSION_NAME}
fi

tmux switch-client -t ${SESSION_NAME}
