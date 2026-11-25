#!/bin/bash

# Usage: kill.sh <session>
# Confirm killing <session> in a popup, then print the fzf actions for the picker to reload the list if it is killed

export DIRECTORY="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# inside the popup, kill the session on yes
if [[ "$1" == --popup ]]; then
    __answer=$(
        printf 'No\nYes\n' | fzf \
            --no-bold \
            --no-sort \
            --ansi \
            --input-border rounded \
            --list-border rounded \
            --color 'border:#56b6c2' \
            --no-info \
            --no-scrollbar \
            --highlight-line \
            --pointer '>' \
            --gutter ' ' \
            --input-label ' Kill Session ' \
            --list-label " $3 " \
            --prompt '> ' \
            --bind 'tab:down,shift-tab:up'
    )

    if [[ "${__answer}" != "Yes" ]]; then
        exit 0
    fi

    if [[ "$(tmux display-message -p '#S')" == "$2" ]]; then
        # move to another session first, otherwise the client is detached
        tmux switch-client -n &>/dev/null

        # the picker in a floating pane goes away with the session, open it again in the next session
        if [[ "${TMUXIONER}" == pane ]]; then
            tmux run-shell -b "$(printf '%q' "${DIRECTORY}/tmuxioner.sh")"
        fi
    fi

    tmux kill-session -t "=$2"
    exit 0
fi

__id="$(tmux display-message -p -t "=$1:" '#{session_id}')"
__position="$(tmux list-sessions -F '#{session_id}' | grep -nxF -- "${__id}" | cut -d: -f1)"

if [[ "$(tmux list-sessions | wc -l)" -le 1 ]]; then
    __header="Kill last session '$1'? tmux server will exit"
else
    __header="Kill session '$1'?"
fi

# fit the question in the label (borders and padding take 6 columns), between 40% and 80% of the window
__window_width="$(tmux display-message -p '#{window_width}')"
__width="$(( $(printf '%s' "${__header}" | wc -L) + 6 ))"
__width="$(( __width < __window_width * 40 / 100 ? __window_width * 40 / 100 : __width ))"
__width="$(( __width > __window_width * 80 / 100 ? __window_width * 80 / 100 : __width ))"

tmux display-popup -E -B -w "${__width}" -h 7 -s 'bg=terminal,fg=terminal' \
    "$(printf '%q ' env "TMUXIONER=${TMUXIONER}" "${DIRECTORY}/kill.sh" --popup "$1" "${__header}")"

# keep the cursor where the killed session was
if ! tmux has-session -t "${__id}" &>/dev/null; then
    printf 'clear-query+reload-sync(tmux list-sessions -F "#S")+wait+pos(%s)' "${__position:-1}"
fi
