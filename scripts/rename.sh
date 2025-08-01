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
    --query "${CURRENT}" \
    --bind 'enter:execute(tmux rename-session -t "${CURRENT}" {q})+become(${DIRECTORY}/tmuxioner.sh)' \
    --bind 'esc:become(${DIRECTORY}/tmuxioner.sh),ctrl-c:become(${DIRECTORY}/tmuxioner.sh),ctrl-g:become(${DIRECTORY}/tmuxioner.sh),ctrl-q:become(${DIRECTORY}/tmuxioner.sh)'
