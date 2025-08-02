#!/bin/bash

export DIRECTORY="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

SESSION=$(
    tmux list-sessions -F \#S | fzf \
        --tmux 80%,90% \
        --no-sort \
        --ansi \
        --border-label ' tmuxioner ' \
        --prompt '> ' \
        --header 'C-n new C-d kill' \
        --bind 'tab:down,shift-tab:up' \
        --bind 'ctrl-n:become(${DIRECTORY}/create.sh)' \
        --bind 'ctrl-d:execute(tmux kill-session -t {})+reload(tmux list-sessions -F \#S)' \
        --preview-window 'right:60%' \
        --preview 'tmux capture-pane -ep -t {}'
)

if [[ -z ${SESSION} ]]; then
    exit 0
fi

tmux switch-client -t ${SESSION}
