#!/bin/bash

export DIRECTORY="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# open the picker in a modal floating pane without border (tmux 3.8+), so the rename and kill dialogs pop up above it
# tmux cannot show a popup above another popup, so on older tmux the picker is a popup that closes while a dialog shows
if [[ -z "${TMUXIONER}" ]]; then
    IFS=$'\t' read -r __window __pane __width __height __path < <(tmux display-message -p $'#{window_id}\t#{pane_id}\t#{window_width}\t#{window_height}\t#{pane_current_path}')

    # 80% width and 90% height in the center, the terminal colours keep the background transparent
    __w="$(( __width * 80 / 100 ))"
    __h="$(( __height * 90 / 100 ))"

    # the picker becomes the active pane, stop the window name from following it until the picker is closed
    __rename="$(tmux show-options -wqv -t "${__window}" automatic-rename)"
    tmux set-option -w -t "${__window}" automatic-rename off

    __error="$(
        tmux new-pane -W -O -K -A -B none -s 'bg=terminal,fg=terminal' \
            -x "${__w}" -y "${__h}" -X "$(( (__width - __w) / 2 ))" -Y "$(( (__height - __h) / 2 ))" \
            -c "${__path}" -e TMUXIONER=pane -e "TMUXIONER_PANE=${__pane}" "$(printf '%q' "$0")" 2>&1
    )"

    # the window is gone if the picker killed its session
    if [[ -n "${__rename}" ]]; then
        tmux set-option -w -t "${__window}" automatic-rename "${__rename}" &>/dev/null
    else
        tmux set-option -wu -t "${__window}" automatic-rename &>/dev/null
    fi

    # tmux before 3.8 refuses the pane, use a popup instead
    # to open a dialog, the picker writes it into TMUXIONER_NEXT and closes, then opens again after the dialog
    if [[ -n "${__error}" ]]; then
        __next="$(mktemp)"

        while tmux display-popup -E -B -w 80% -h 90% -s 'bg=terminal,fg=terminal' -d "${__path}" \
            "$(printf '%q ' env TMUXIONER=popup "TMUXIONER_NEXT=${__next}" "$0")" &&
            { read -r __dialog && read -r __session; } < "${__next}"; do
            : > "${__next}"
            "${DIRECTORY}/${__dialog}.sh" "${__session}" > /dev/null
        done

        rm -f -- "${__next}"
    fi

    exit 0
fi

__hints=' A-c create  A-m mockup  A-r rename  A-d kill '

if [[ "${TMUXIONER}" == pane ]]; then
    # a modal pane takes all keys, never leave it behind as a dead pane
    tmux set-option -p -t "${TMUX_PANE}" remain-on-exit off

    # the dialog pops up above the picker, then prints the fzf actions to reload the list
    __rename='transform:"${DIRECTORY}/rename.sh" {}'
    __kill='transform:"${DIRECTORY}/kill.sh" {}'
else
    # the launcher opens the dialog after the popup closes
    __rename='execute-silent(printf "rename\n%s\n" {} > "${TMUXIONER_NEXT}")+abort'
    __kill='execute-silent(printf "kill\n%s\n" {} > "${TMUXIONER_NEXT}")+abort'
fi

SESSION=$(
    tmux list-sessions -F \#S | fzf \
        --no-bold \
        --no-sort \
        --ansi \
        --input-border rounded \
        --list-border rounded \
        --preview-border rounded \
        --info inline-right \
        --no-scrollbar \
        --highlight-line \
        --pointer '>' \
        --gutter ' ' \
        --input-label ' Sessions ' \
        --list-label "${__hints}" \
        --list-label-pos 0:bottom \
        --prompt '> ' \
        --bind 'tab:down,shift-tab:up' \
        --bind 'alt-c:become("${DIRECTORY}/create.sh")' \
        --bind 'alt-m:become("${DIRECTORY}/session.sh" "${HOME}" "$(tr -dc "A-Za-z0-9" < /dev/urandom | head -c 10)")' \
        --bind "alt-r:${__rename}" \
        --bind "alt-d:${__kill}" \
        --bind 'focus:transform-preview-label:printf " %s " {}' \
        --preview-window 'right:60%' \
        --preview '"${DIRECTORY}/preview.sh" {}'
)

if [[ -z ${SESSION} ]]; then
    exit 0
fi

tmux switch-client -t "=${SESSION}"
