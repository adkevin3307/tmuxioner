#!/bin/bash

export DIRECTORY="$1"
export CURRENT="$2"

builtin cd "${CURRENT}"

while true; do
    __directory=$(
        ls -lhago | python3 ${DIRECTORY}/scripts/preprocess.py | fzf \
            --tmux 80%,90% \
            --no-sort \
            --ansi \
            --border-label ' tmuxioner ' \
            --prompt '> ' \
            --header 'C-s session A-enter create' \
            --bind 'tab:down,shift-tab:up' \
            --bind 'backward-eof:become(echo "..")' \
            --bind 'alt-enter:become(__path=$(realpath $(echo {} | python3 ${DIRECTORY}/scripts/postprocess.py)); __name=$(basename ${__path}); tmux has-session -t ${__name} &>/dev/null || tmux new-session -d -s ${__name} -c ${__path}; tmux switch-client -t ${__name};)' \
            --bind 'ctrl-s:become(${DIRECTORY}/scripts/tmuxioner.sh "${DIRECTORY}" "${CURRENT}")' \
            --preview-window 'right:60%' \
            --preview 'ls -lha --color=always $(echo {} | python3 ${DIRECTORY}/scripts/postprocess.py)' | python3 ${DIRECTORY}/scripts/postprocess.py
    )

    [[ ${#__directory} != 0 ]] || break

    builtin cd "${__directory}" &>/dev/null
done
