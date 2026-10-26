#!/bin/bash

export DIRECTORY="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

SESSION=$(
    tmux list-sessions -F \#S | fzf \
        --tmux 80%,90% \
        --no-bold \
        --no-sort \
        --ansi \
        --border-label ' tmuxioner ' \
        --prompt '> ' \
        --header 'A-c create A-m mockup A-r rename A-d kill' \
        --bind 'tab:down,shift-tab:up' \
        --bind 'alt-c:become("${DIRECTORY}/create.sh")' \
        --bind 'alt-m:become("${DIRECTORY}/session.sh" "${HOME}" "$(tr -dc "A-Za-z0-9" < /dev/urandom | head -c 10)")' \
        --bind 'alt-r:become("${DIRECTORY}/rename.sh" {})' \
        --bind 'alt-d:become("${DIRECTORY}/kill.sh" {})' \
        --preview-window 'right:60%' \
        --preview 'tmux capture-pane -ep -t {}'
)

if [[ -z ${SESSION} ]]; then
    exit 0
fi

tmux switch-client -t "=${SESSION}"
