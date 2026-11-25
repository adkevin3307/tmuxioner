#!/bin/bash

# Usage: preview.sh <session>
# Print the active pane of <session>, or the pane the picker was opened from when the picker itself is the active pane

__pane="$(tmux display-message -p -t "=$1:" '#{pane_id}')"

if [[ "${__pane}" == "${TMUX_PANE}" ]]; then
    __pane="${TMUXIONER_PANE}"
fi

tmux capture-pane -ep -t "${__pane}"
