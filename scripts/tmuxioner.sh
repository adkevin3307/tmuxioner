#!/bin/bash

export DIRECTORY="$1"

SESSION=$(tmux list-sessions -F \#S | fzf \
    --tmux 80%,90% \
    --no-sort \
    --ansi \
    --border-label ' tmux ' \
    --prompt '> ' \
    --header '^n new ^d kill' \
    --bind 'tab:down,shift-tab:up' \
    --bind 'ctrl-n:become(${DIRECTORY}/scripts/create.sh "${DIRECTORY}")' \
    --bind 'ctrl-d:execute(tmux kill-session -t {})+reload(tmux list-sessions -F \#S)' \
    --preview-window 'right:60%' \
    --preview 'tmux capture-pane -ep -t {}'
)

if [[ -z ${SESSION} ]]; then
    exit 0
fi

tmux switch-client -t ${SESSION}
