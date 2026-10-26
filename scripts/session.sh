#!/bin/bash

# Usage: session.sh <path> [name]
# Switch to session <name> (default: basename of <path>), create it in <path> if not exist

__path="$(realpath -- "$1")"
__name="${2:-$(basename "${__path}")}"

# tmux does not allow '.' and ':' in session names
__name="${__name//[.:]/_}"

tmux has-session -t "=${__name}" &>/dev/null || tmux new-session -d -s "${__name}" -c "${__path}"
tmux switch-client -t "=${__name}"
