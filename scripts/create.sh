#!/bin/bash

export DIRECTORY="$1"

SELECTION=$(__directories=$(fd -H -d 1 -t d -a | sed "s;/$;;" && echo $(realpath "..")); printf "%s\n" "${__directories[@]}" | fzf \
    --tmux 80%,90% \
    --no-sort \
    --ansi \
    --border-label ' tmuxioner ' \
    --prompt '> ' \
    --header '^s session' \
    --bind 'ctrl-s:become(${DIRECTORY}/scripts/tmuxioner.sh "${DIRECTORY}")' \
    --bind 'tab:reload(cd {}; __directories=$(fd -H -d 1 -t d -a | sed "s;/$;;" && echo $(realpath "..")); printf "%s\n" "${__directories[@]}";)' \
    --preview-window 'right:60%' \
    --preview 'ls -lha --color=always {}'
)

if [[ -z ${SELECTION} ]]; then
    exit 0
fi

SESSION=$(basename ${SELECTION})

tmux has-session -t ${SESSION} 2>/dev/null

if [[ ! $? == 0 ]]; then
    tmux new-session -d -c ${SELECTION} -s ${SESSION}
fi

tmux switch-client -t ${SESSION}
