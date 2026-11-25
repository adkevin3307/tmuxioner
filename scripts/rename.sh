#!/bin/bash

# Usage: rename.sh <session>
# Ask for a new name of <session> in a popup, then print the fzf actions for the picker to reload the list if it is renamed

export DIRECTORY="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# inside the popup, enter renames or stays to show why tmux refuses the name, e.g. a duplicate session
if [[ "$1" == --popup ]]; then
    export TARGET="$2"

    __enter='transform:
        if [ -n "${FZF_QUERY}" ] && [ "${FZF_QUERY}" != "${TARGET}" ] && ! __error="$(tmux rename-session -t "=${TARGET}" -- "${FZF_QUERY}" 2>&1)"; then
            printf "change-border-label: %s " "${__error}"
        else
            echo abort
        fi'

    exec fzf < /dev/null \
        --no-bold \
        --disabled \
        --no-info \
        --border rounded \
        --border-label ' Rename Session ' \
        --prompt '> ' \
        --query "${TARGET}" \
        --ghost "${TARGET}" \
        --bind "enter:${__enter}" \
        --bind 'change:change-border-label( Rename Session )'
fi

__id="$(tmux display-message -p -t "=$1:" '#{session_id}')"

# fit the name in a single line (border, padding, prompt and cursor take 8 columns), between 40% and 80% of the window
__window_width="$(tmux display-message -p '#{window_width}')"
__width="$(( $(printf '%s' "$1" | wc -L) + 8 ))"
__width="$(( __width < __window_width * 40 / 100 ? __window_width * 40 / 100 : __width ))"
__width="$(( __width > __window_width * 80 / 100 ? __window_width * 80 / 100 : __width ))"

tmux display-popup -E -B -w "${__width}" -h 3 -s 'bg=terminal,fg=terminal' "$(printf '%q ' "${DIRECTORY}/rename.sh" --popup "$1")"

# follow the session by id, its position in the list may change with the name
if [[ "$(tmux display-message -p -t "${__id}:" '#S')" != "$1" ]]; then
    __position="$(tmux list-sessions -F '#{session_id}' | grep -nxF -- "${__id}" | cut -d: -f1)"

    printf 'clear-query+reload-sync(tmux list-sessions -F "#S")+wait+pos(%s)' "${__position:-1}"
fi
