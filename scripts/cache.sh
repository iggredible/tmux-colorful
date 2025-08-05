#!/usr/bin/env bash

# Cache directory in tmux environment
CACHE_PREFIX="@tmux_colorful_cache_"
CACHE_TIME_PREFIX="@tmux_colorful_cache_time_"

# Get cache duration for a specific plugin
get_cache_duration() {
    local plugin=$1
    local duration_var="@tmux_colorful_cache_duration_${plugin}"
    local custom_duration=$(tmux show-option -gqv "$duration_var")

    # Default cache durations (in seconds)
    case $plugin in
        cpu)
            echo ${custom_duration:-5}
            ;;
        battery)
            echo ${custom_duration:-30}
            ;;
        network)
            echo ${custom_duration:-10}
            ;;
        git)
            echo ${custom_duration:-5}
            ;;
        *)
            echo ${custom_duration:-5}
            ;;
    esac
}

# Check if cache is valid
is_cache_valid() {
    local plugin=$1
    local cache_time_var="${CACHE_TIME_PREFIX}${plugin}"
    local cached_time=$(tmux show-option -gqv "$cache_time_var")

    if [ -z "$cached_time" ]; then
        return 1  # No cache exists
    fi

    local current_time=$(date +%s)
    local cache_duration=$(get_cache_duration "$plugin")
    local expire_time=$((cached_time + cache_duration))

    if [ $current_time -lt $expire_time ]; then
        return 0  # Cache is still valid
    else
        return 1  # Cache has expired
    fi
}

# Get cached value
get_cached_value() {
    local plugin=$1
    local cache_var="${CACHE_PREFIX}${plugin}"

    if is_cache_valid "$plugin"; then
        tmux show-option -gqv "$cache_var"
        return 0
    else
        return 1
    fi
}

# Set cache value
set_cache_value() {
    local plugin=$1
    local value=$2
    local cache_var="${CACHE_PREFIX}${plugin}"
    local cache_time_var="${CACHE_TIME_PREFIX}${plugin}"
    local current_time=$(date +%s)

    tmux set-option -gq "$cache_var" "$value"
    tmux set-option -gq "$cache_time_var" "$current_time"
}

# Clear cache for a specific plugin
clear_cache() {
    local plugin=$1
    local cache_var="${CACHE_PREFIX}${plugin}"
    local cache_time_var="${CACHE_TIME_PREFIX}${plugin}"

    tmux set-option -gqu "$cache_var"
    tmux set-option -gqu "$cache_time_var"
}

# Clear all caches
clear_all_caches() {
    for var in $(tmux show-options -g | grep "^${CACHE_PREFIX}" | cut -d' ' -f1); do
        tmux set-option -gqu "$var"
    done
    for var in $(tmux show-options -g | grep "^${CACHE_TIME_PREFIX}" | cut -d' ' -f1); do
        tmux set-option -gqu "$var"
    done
}

# Execute plugin with caching
execute_with_cache() {
    local plugin=$1
    local script_path=$2

    # Try to get cached value first
    local cached_value=$(get_cached_value "$plugin")
    if [ $? -eq 0 ]; then
        echo "$cached_value"
        return 0
    fi

    # Execute the script and cache the result
    local result=$("$script_path")
    set_cache_value "$plugin" "$result"
    echo "$result"
}
