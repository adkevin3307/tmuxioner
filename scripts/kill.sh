#!/bin/bash

export DIRECTORY="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
export TARGET="$1"

if [[ "$(tmux list-sessions | wc -l)" -le 1 ]]; then
    __header="Kill last session '${TARGET}'? tmux server will exit"
else
    __header="Kill session '${TARGET}'?"
fi

__answer=$(
    printf 'No\nYes\n' | fzf \
        --tmux 40%,7 \
        --no-bold \
        --no-sort \
        --ansi \
        --border none \
        --input-border rounded \
        --list-border rounded \
        --no-info \
        --no-scrollbar \
        --highlight-line \
        --pointer '>' \
        --gutter ' ' \
        --input-label ' Kill Session ' \
        --list-label " ${__header} " \
        --prompt '> ' \
        --bind 'tab:down,shift-tab:up'
)

if [[ "${__answer}" == "Yes" ]]; then
    # move to another session first, otherwise the client is detached
    if [[ "$(tmux display-message -p '#S')" == "${TARGET}" ]]; then
        tmux switch-client -n &>/dev/null
    fi

    tmux kill-session -t "=${TARGET}"
fi

exec "${DIRECTORY}/tmuxioner.sh"
