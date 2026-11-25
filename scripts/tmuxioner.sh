#!/bin/bash

export DIRECTORY="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

__label=' Sessions '
__hints=' A-c create  A-m mockup  A-r rename  A-d kill '

# rename in place instead of opening another popup (tmux shows one popup at a time), so the picker stays on screen
# rename mode disables search, keeps the session to rename as the ghost text and unbinds keys that move or leave
__keys='alt-c,alt-m,alt-r,alt-d,tab,shift-tab,up,down,ctrl-j,ctrl-k,ctrl-n,ctrl-p,page-up,page-down,left-click,double-click,scroll-up,scroll-down'
__rename_mode="disable-search+change-input-label( Rename Session )+change-list-label( enter rename  esc cancel )+unbind(${__keys})+transform-query(printf %s {})+transform-ghost(printf %s {})"
export SEARCH_MODE="enable-search+clear-query+change-ghost()+change-input-label(${__label})+change-list-label(${__hints})+rebind(${__keys})"

# enter renames and cancel keys go back to search mode while renaming
__enter='transform:if [ "${FZF_INPUT_STATE}" = disabled ]; then "${DIRECTORY}/rename.sh"; else echo accept; fi'
__cancel='transform:if [ "${FZF_INPUT_STATE}" = disabled ]; then printf %s "${SEARCH_MODE}"; else echo abort; fi'

# restyle the popup from inside with the terminal colours instead of popup-style, so the background is transparent
SESSION=$(
    tmux list-sessions -F \#S | fzf \
        --tmux 80%,90% \
        --no-bold \
        --no-sort \
        --ansi \
        --border none \
        --input-border rounded \
        --list-border rounded \
        --preview-border rounded \
        --info inline-right \
        --no-scrollbar \
        --highlight-line \
        --pointer '>' \
        --gutter ' ' \
        --input-label "${__label}" \
        --list-label "${__hints}" \
        --list-label-pos 0:bottom \
        --prompt '> ' \
        --bind 'start:execute-silent(tmux display-popup -s "bg=terminal,fg=terminal")' \
        --bind 'tab:down,shift-tab:up' \
        --bind 'alt-c:become("${DIRECTORY}/create.sh")' \
        --bind 'alt-m:become("${DIRECTORY}/session.sh" "${HOME}" "$(tr -dc "A-Za-z0-9" < /dev/urandom | head -c 10)")' \
        --bind "alt-r:${__rename_mode}" \
        --bind 'alt-d:become("${DIRECTORY}/kill.sh" {})' \
        --bind "enter:${__enter}" \
        --bind "esc:${__cancel}" \
        --bind "ctrl-c:${__cancel}" \
        --bind "ctrl-g:${__cancel}" \
        --bind "ctrl-q:${__cancel}" \
        --bind 'focus:transform-preview-label:printf " %s " {}' \
        --preview-window 'right:60%' \
        --preview 'tmux capture-pane -ep -t {}'
)

if [[ -z ${SESSION} ]]; then
    exit 0
fi

tmux switch-client -t "=${SESSION}"
