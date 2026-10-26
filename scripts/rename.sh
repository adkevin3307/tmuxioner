#!/bin/bash

export DIRECTORY="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
export CURRENT="$1"

# fit the name in a single line (border, margin, prompt and cursor take 9 columns), between 20% and 80% of the window
__window_width="$(tmux display-message -p '#{window_width}')"
__width="$(( $(printf '%s' "${CURRENT}" | wc -L) + 9 ))"
__width="$(( __width < __window_width * 20 / 100 ? __window_width * 20 / 100 : __width ))"
__width="$(( __width > __window_width * 80 / 100 ? __window_width * 80 / 100 : __width ))"

# height 5 is the minimum of fzf, a single line of input
fzf < /dev/null \
    --tmux "${__width},5" \
    --no-bold \
    --no-sort \
    --ansi \
    --border-label ' tmuxioner ' \
    --prompt '> ' \
    --no-info \
    --no-separator \
    --disabled \
    --ghost 'Session Name' \
    --query "${CURRENT}" \
    --bind 'enter:execute([ -n {q} ] && tmux rename-session -t "=${CURRENT}" {q})+become("${DIRECTORY}/tmuxioner.sh")' \
    --bind 'esc:become("${DIRECTORY}/tmuxioner.sh"),ctrl-c:become("${DIRECTORY}/tmuxioner.sh"),ctrl-g:become("${DIRECTORY}/tmuxioner.sh"),ctrl-q:become("${DIRECTORY}/tmuxioner.sh")'
