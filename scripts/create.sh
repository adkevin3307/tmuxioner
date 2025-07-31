#!/bin/bash

export DIRECTORY="$1"

while true; do
    __directories=$(ls -ap --color=always | grep '/$' | sed 's;/$;;')
    __directory=$(
        printf '%s\n' "${__directories[@]}" | fzf \
            --tmux 80%,90% \
            --no-sort \
            --ansi \
            --border-label ' tmuxioner ' \
            --prompt '> ' \
            --header '^s session' \
            --bind 'tab:down,shift-tab:up' \
            --bind 'backspace:become(echo "..")' \
            --bind 'alt-enter:become(tmux has-session -t {} &>/dev/null || tmux new-session -d -s {} -c $(pwd)/{}; tmux switch-client -t {};)' \
            --bind 'ctrl-s:become(${DIRECTORY}/scripts/tmuxioner.sh "${DIRECTORY}")' \
            --preview-window 'right:60%' \
            --preview 'ls -lha --color=always {}'
    )

    [[ ${#__directory} != 0 ]] || break

    builtin cd "${__directory}" &>/dev/null
done
