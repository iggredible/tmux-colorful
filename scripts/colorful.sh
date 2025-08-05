#!/usr/bin/env bash

current_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

source $current_dir/utils.sh

color_scheme=$(get_tmux_option '@tmux_colorful_color_scheme' 'https://coolors.co/fbf900-2bffff-353643-3b9778-74112f')

IFS="-";

read -a colors <<< "${color_scheme##*/}"

light=$(get_tmux_option '@tmux_colorful_light' '#ffffff')
dark=$(get_tmux_option '@tmux_colorful_dark' '#000000')

color_primary=$(get_tmux_option '@tmux_colorful_color_primary' "#${colors[3]}")
color_secondary=$(get_tmux_option '@tmux_colorful_color_secondary' "#${colors[4]}")
foreground_color_primary=$(calculate_contrast_yiq $color_primary)
foreground_color_secondary=$(calculate_contrast_yiq $color_secondary)

IFS=' ' read -r -a plugins <<< $(get_tmux_option "@tmux_colorful_plugins" "cpu battery date")

# Right status bar
tmux set-option -g status-right ""
tmux set-option -g status-right-length 120

# Plugins
color_counter=0
for plugin in "${plugins[@]}"; do
  if [ $plugin = "battery" ]; then
    battery_life_icon=$(get_tmux_option '@tmux_colorful_battery_life_icon' '♥')
    battery_level=$("$current_dir/battery_info.sh")
    script="$battery_life_icon $battery_level%"
  fi

  if [ $plugin = "cpu" ]; then
    cpu_info=$("$current_dir/cpu_info.sh")
    script="CPU $cpu_info%%"
  fi

  if [ $plugin = "date" ]; then
    date_icon="$(get_tmux_option '@tmux_colorful_date_icon' '')"
    date_format=$(get_tmux_option @tmux_colorful_date_format '%D')
    script="$date_icon $date_format"
  fi

  if [ $plugin = "time" ]; then
    time_icon="$(get_tmux_option '@tmux_colorful_time_icon' '')"
    time_format=$(get_tmux_option @tmux_colorful_time_format '%T')
    script="$time_icon $time_format"
  fi

  if [ $plugin = "network" ]; then
    network_info=$("$current_dir/network_info.sh")
    script="$network_info"
  fi

  if [ $plugin = "git" ]; then
    git_info=$("$current_dir/git_info.sh")
    script="$git_info"
  fi

  if [ "${color_counter}" -eq "${#colors[@]}" ]; then
    ((color_counter=0))
  fi

  # Right status bar
  background_color=$(get_tmux_option "@tmux_colorful_color_${color_counter}" "#${colors[color_counter]}")
  foreground_color=$(calculate_contrast_yiq $background_color)

  tmux set-option -ga status-right "#[fg=$foreground_color,bg=$background_color] $script "

  ((color_counter=color_counter+1))
done

# Left status bar
left_status_bar=$(get_tmux_option '@tmux_colorful_left_status_bar' '#S')
LS="#[fg=$foreground_color_primary,bg=$color_primary,bold] $left_status_bar "
set_tmux_option status-left "$LS"
tmux set-option -g status-left-length 30

# Windows information
window_status=$(get_tmux_option '@tmux_colorful_window_status' '#I:#W#F')
set_tmux_option window-status-current-format "#[fg=$foreground_color_secondary,bg=$color_secondary,bold] $window_status "
set_tmux_option window-status-format " $window_status "

# Windows
set_tmux_option window-status-separator ""
set_tmux_option window-status-current-style "fg=$color_primary,bg=$dark"

# Status options
status_interval=$(get_tmux_option '@tmux_colorful_status_interval' 1)
set_tmux_option status-interval $status_interval
set_tmux_option status on

# Panes
set_tmux_option pane-border-style "fg=$dark"
set_tmux_option pane-active-border-style "fg=$color_primary,bg=$dark"
set_tmux_option display-panes-colour "$dark"
set_tmux_option display-panes-active-colour "$color_primary"

# Clock mode
clock_mode_color=$(get_tmux_option '@tmux_colorful_clock_mode_color' $color_primary)
clock_mode_style=$(get_tmux_option @tmux_colorful_clock_mode_style 24)
set_tmux_option clock-mode-colour $clock_mode_color
set_tmux_option clock-mode-style $clock_mode_style

# Copy mode highlight
copy_mode_highlight=$(get_tmux_option '@tmux_colorful_copy_mode_highlight' "$bg=$color_primary")
set_tmux_option mode-style $copy_mode_highlight

# Overall status bar
status_bg=$(get_tmux_option '@tmux_colorful_status_bg' $dark)
status_fg=$(get_tmux_option '@tmux_colorful_status_fg' $light)
status_justify=$(get_tmux_option @tmux_colorful_status_justify_format 'left')
set_tmux_option status-bg $status_bg
set_tmux_option status-fg $status_fg
set_tmux_option status-justify $status_justify
