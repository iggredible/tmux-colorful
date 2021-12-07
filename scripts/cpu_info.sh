#!/usr/bin/env bash
current_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source $current_dir/utils.sh

get_percent()
{
  case $(uname -s) in
    Linux)
      percent=$(LC_NUMERIC=en_US.UTF-8 top -bn2 -d 0.01 | grep "Cpu(s)" | tail -1 | sed "s/.*, *\([0-9.]*\)%* id.*/\1/" | awk '{print 100 - $1"%"}')
      echo $percent
      ;;

    Darwin)
      cpuvalue=$(ps -A -o %cpu | awk -F. '{s+=$1} END {print s}')
      cpucores=$(sysctl -n hw.logicalcpu)
      cpuusage=$(( cpuvalue / cpucores ))
      percent="$cpuusage"
      echo $percent
      ;;

  esac
}

main()
{
  # storing the refresh rate in the variable RATE, default is 5
  cpu_percent=$(get_percent)
  echo "$cpu_percent"
}

# run main driver
main
