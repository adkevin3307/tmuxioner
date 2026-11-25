#!/bin/bash

export DIRECTORY="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# popup width and preview width in percentage, the list layout in preprocess.py depends on them
export WIDTH=80
export PREVIEW=60

# traverse by reloading the list in place instead of restarting fzf, so the popup does not flash
__list='python3 "${DIRECTORY}/preprocess.py" "${WIDTH}" "$((100 - PREVIEW))"'

python3 "${DIRECTORY}/preprocess.py" "${WIDTH}" "$((100 - PREVIEW))" "$(tmux display-message -p "#{pane_current_path}")" | fzf \
    --tmux "${WIDTH}%,90%" \
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
    --input-label ' Create Session ' \
    --list-label ' A-enter create ' \
    --list-label-pos 0:bottom \
    --prompt '> ' \
    --delimiter '\t' \
    --with-nth 2 \
    --bind 'tab:down,shift-tab:up' \
    --bind "enter:clear-query+reload-sync(${__list} {1})+first" \
    --bind "backward-eof:pos(2)+reload-sync(${__list} {1})+first" \
    --bind 'alt-enter:become("${DIRECTORY}/session.sh" {1})' \
    --bind 'esc:become("${DIRECTORY}/tmuxioner.sh"),ctrl-c:become("${DIRECTORY}/tmuxioner.sh"),ctrl-g:become("${DIRECTORY}/tmuxioner.sh"),ctrl-q:become("${DIRECTORY}/tmuxioner.sh")' \
    --bind 'focus:transform-preview-label:printf " %s " {1}' \
    --preview-window "right:${PREVIEW}%" \
    --preview 'ls -lha --color=always -- {1}'
