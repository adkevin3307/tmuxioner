#!/bin/bash

# Usage: called by the fzf transform on enter in rename mode of tmuxioner.sh, prints the fzf actions to run next
# The query is the new name and the ghost text is the session to rename

__id="$(tmux display-message -p -t "=${FZF_GHOST}:" '#{session_id}')"

if [[ -n "${FZF_QUERY}" && "${FZF_QUERY}" != "${FZF_GHOST}" ]]; then
    # stay in rename mode and show why tmux refuses the name, e.g. a duplicate session
    if ! __error="$(tmux rename-session -t "=${FZF_GHOST}" -- "${FZF_QUERY}" 2>&1)"; then
        printf 'change-list-label: %s ' "${__error}"
        exit 0
    fi
fi

# back to search mode on the renamed session, follow it by id since its position in the list may change
__position="$(tmux list-sessions -F '#{session_id}' | grep -nxF -- "${__id}" | cut -d: -f1)"

printf '%s+reload-sync(tmux list-sessions -F "#S")+pos(%s)' "${SEARCH_MODE}" "${__position:-1}"
