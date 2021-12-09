#!/usr/bin/env bash

current_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

source $current_dir/utils.sh

color_scheme=$(get_tmux_option '@tmux_colorful_color_scheme' 'https://coolors.co/313e61-74112f-fbf900-2bffff-fad02c')

IFS="-";

read -a colors <<< "${color_scheme##*/}"

light=$(get_tmux_option '@tmux_colorful_light' '#ffffff')
dark=$(get_tmux_option '@tmux_colorful_dark' '#000000')

color1=$(get_tmux_option '@tmux_colorful_color1' "#${colors[0]}")
color2=$(get_tmux_option '@tmux_colorful_color2' "#${colors[1]}")
color3=$(get_tmux_option '@tmux_colorful_color3' "#${colors[2]}")
color4=$(get_tmux_option '@tmux_colorful_color4' "#${colors[3]}")
color5=$(get_tmux_option '@tmux_colorful_color5' "#${colors[4]}")

text_color1=$(get_tmux_option '@tmux_colorful_text_color1' $light)
text_color2=$(get_tmux_option '@tmux_colorful_text_color2' $light)
text_color3=$(get_tmux_option '@tmux_colorful_text_color3' $dark)
text_color4=$(get_tmux_option '@tmux_colorful_text_color4' $dark)
text_color5=$(get_tmux_option '@tmux_colorful_text_color5' $dark)

# Arrow icons
right_arrow_icon=$(get_tmux_option '@tmux_colorful_right_arrow_icon' '')
left_arrow_icon=$(get_tmux_option '@tmux_colorful_left_arrow_icon' '')

# Time
time_icon="$(get_tmux_option '@tmux_colorful_time_icon' '')"
time_format=$(get_tmux_option @tmux_colorful_time_format '%T')
display_time="$time_icon $time_format"

# Date
date_icon="$(get_tmux_option '@tmux_colorful_date_icon' '')"
date_format=$(get_tmux_option @tmux_colorful_date_format '%F')
display_date="$date_icon $date_format"

# Battery
battery_life_icon=$(get_tmux_option '@tmux_colorful_battery_life_icon' '♥')
battery_level=$("$current_dir/battery_info.sh")
display_battery="$battery_life_icon $battery_level%"

# CPU
cpu_info=$("$current_dir/cpu_info.sh")
display_cpu="CPU $cpu_info%%"

# Network
network_info=$("$current_dir/network_info.sh")
display_network="$network_info"

# RAM
ram_info=$("$current_dir/ram_info.sh")
display_ram="$ram_info"

# Git
git_info=$("$current_dir/git_info.sh")
display_git="$git_info"

left_status_bar_1=$(get_tmux_option '@tmux_colorful_left_status_bar_1' '#S')
left_status_bar_2=$(get_tmux_option '@tmux_colorful_left_status_bar_2' '#I:#W#F')
right_status_bar_3=$(get_tmux_option '@tmux_colorful_right_status_bar_3' $display_cpu)
right_status_bar_4=$(get_tmux_option '@tmux_colorful_right_status_bar_4' $display_battery)
right_status_bar_5=$(get_tmux_option '@tmux_colorful_right_status_bar_5' $display_date)

# Left status bar
# (1) = session name
LS="#[fg=$text_color1,bg=$color1,bold] $left_status_bar_1 #[fg=$color1,bg=$dark]$right_arrow_icon"
set_tmux_option status-left "$LS"

# Left status bar
# (2) = window names
set_tmux_option window-status-current-format "#[bg=$color2,fg=$text_color2,bold] $left_status_bar_2 #[fg=$color2,bg=$dark,nobold]$right_arrow_icon"
set_tmux_option window-status-format " $left_status_bar_2 "

# Right status bar
# (3), (4), and (5)
RS3="#[fg=$color3,bg=$dark]$left_arrow_icon#[fg=$text_color3,bg=$color3] $right_status_bar_3"
RS4="#[fg=$color4,bg=$color3]$left_arrow_icon#[fg=$text_color4,bg=$color4] $right_status_bar_4"
RS5="#[fg=$color5,bg=$color4]$left_arrow_icon#[fg=$text_color5,bg=$color5] $right_status_bar_5"
RS="$RS3 $RS4 $RS5 "
set_tmux_option status-right "$RS"

# Status options
status_interval=$(get_tmux_option '@tmux_colorful_status_interval' 10)
set_tmux_option status-interval $status_interval
set_tmux_option status on

# Windows
set_tmux_option window-status-separator ""
set_tmux_option window-status-current-style "fg=$color1,bg=$dark"

# Panes
set_tmux_option pane-border-style "fg=$dark"
set_tmux_option pane-active-border-style "fg=$color1,bg=$dark"
set_tmux_option display-panes-colour "$dark"
set_tmux_option display-panes-active-colour "$color1"

# Clock mode
clock_mode_color=$(get_tmux_option '@tmux_colorful_clock_mode_color' $color1)
clock_mode_style=$(get_tmux_option @tmux_colorful_clock_mode_style 24)
set_tmux_option clock-mode-colour $clock_mode_color
set_tmux_option clock-mode-style $clock_mode_style

# Copy mode highlight
copy_mode_highlight=$(get_tmux_option '@tmux_colorful_copy_mode_highlight' "$bg=$color1")
set_tmux_option mode-style $copy_mode_highlight

# Overall status bar
status_bg=$(get_tmux_option '@tmux_colorful_status_bg' $dark)
status_fg=$(get_tmux_option '@tmux_colorful_status_fg' $light)
set_tmux_option status-bg $status_bg
set_tmux_option status-fg $status_fg

status_justify=$(get_tmux_option @tmux_colorful_status_justify_format 'left')
set_tmux_option status-justify $status_justify

