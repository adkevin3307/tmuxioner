#!/bin/bash

export DIRECTORY="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
export CURRENT="$1"

fzf \
    --tmux 30%,10% \
    --no-sort \
    --ansi \
    --border-label ' tmuxioner ' \
    --prompt '> ' \
    --no-info \
    --no-separator \
    --disabled \
    --ghost 'Session Name' \
    --bind 'enter:execute(tmux rename-session -t ${CURRENT} {q})+become(${DIRECTORY}/tmuxioner.sh)'
