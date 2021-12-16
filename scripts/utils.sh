#!/usr/bin/env bash

get_tmux_option() {
    local value="$(tmux show-option -gqv "$1")"
    [ -n "$value" ] && echo "$value" || echo "$2"
}

set_tmux_option() {
    tmux set-option -gq "$1" "$2"
}

calculate_contrast_yiq() {
    color="$1"

    r_hex=${color:1:2}
    g_hex=${color:3:2}
    b_hex=${color:5:2}

    r_dec=$((16#$r_hex))
    g_dec=$((16#$g_hex))
    b_dec=$((16#$b_hex))

    ((yiq=((r_dec*299)+(g_dec*587)+(b_dec*114))/1000))

    echo $(if (( $yiq > 128 )); then echo "#000000"; else echo "#ffffff"; fi)
}
