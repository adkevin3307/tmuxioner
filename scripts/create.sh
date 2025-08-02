#!/bin/bash

export DIRECTORY="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

builtin cd "$(tmux display-message -p "#{pane_current_path}")"

while true; do
    __directory=$(
        ls -lhago | python3 ${DIRECTORY}/preprocess.py | fzf \
            --tmux 80%,90% \
            --no-sort \
            --ansi \
            --border-label ' tmuxioner ' \
            --prompt '> ' \
            --header 'A-s session A-enter create' \
            --bind 'tab:down,shift-tab:up' \
            --bind 'backward-eof:become(echo "..")' \
            --bind 'alt-enter:become(__path=$(realpath $(echo {} | python3 ${DIRECTORY}/postprocess.py)); __name=$(basename ${__path}); tmux has-session -t ${__name} &>/dev/null || tmux new-session -d -s ${__name} -c ${__path}; tmux switch-client -t ${__name};)' \
            --bind 'alt-s:become(${DIRECTORY}/tmuxioner.sh)' \
            --preview-window 'right:60%' \
            --preview 'ls -lha --color=always $(echo {} | python3 ${DIRECTORY}/postprocess.py)' | python3 ${DIRECTORY}/postprocess.py
    )

    [[ ${#__directory} != 0 ]] || break

    builtin cd "${__directory}" &>/dev/null
done
