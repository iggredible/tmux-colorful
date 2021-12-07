#!/usr/bin/env bash

get_tmux_option() {
    local value="$(tmux show-option -gqv "$1")"
    [ -n "$value" ] && echo "$value" || echo "$2"
}

set_tmux_option() {
    tmux set-option -gq "$1" "$2"
}
