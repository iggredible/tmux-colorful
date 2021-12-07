#!/usr/bin/env bash

current_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source $current_dir/utils.sh

IFS=' ' read -r -a hide_status <<< $(get_tmux_option "@tmux_colorful_git_disable_status" "false")
IFS=' ' read -r -a current_symbol <<< $(get_tmux_option "@tmux_colorful_git_show_current_symbol" "✓")
IFS=' ' read -r -a diff_symbol <<< $(get_tmux_option "@tmux_colorful_git_show_diff_symbol" "!")
IFS=' ' read -r -a no_repo_message <<< $(get_tmux_option "@tmux_colorful_git_no_repo_message" "")

# Get added, modified, updated and deleted files from git status
getChanges()
{
   declare -i added=0;
   declare -i modified=0;
   declare -i updated=0;
   declare -i deleted=0;

for i in $(git -C $path status -s)

    do
      case $i in 
      'A')
        added+=1 
      ;;
      'M')
        modified+=1
      ;;
      'U')
        updated+=1 
      ;;
      'D')
       deleted+=1
      ;;

      esac
    done

    output=""
    [ $added -gt 0 ] && output+="${added}A"
    [ $modified -gt 0 ] && output+=" ${modified}M"
    [ $updated -gt 0 ] && output+=" ${updated}U"
    [ $deleted -gt 0 ] && output+=" ${deleted}D"
  
    echo $output    
}


getPaneDir()
{
 nextone="false"
 for i in $(tmux list-panes -F "#{pane_active} #{pane_current_path}");
 do
    if [ "$nextone" == "true" ]; then
       echo $i
       return
    fi 
    if [ "$i" == "1" ]; then
        nextone="true"
    fi
  done
}


# check if the current or diff symbol is empty to remove ugly padding
checkEmptySymbol()
{
    symbol=$1    
    if [ "$symbol" == "" ]; then
        echo "true"
    else
        echo "false"
    fi
}

# check to see if the current repo is not up to date with HEAD
checkForChanges()
{
    if [ "$(checkForGitDir)" == "true" ]; then
        if [ "$(git -C $path status -s)" != "" ]; then
            echo "true"
        else
            echo "false"
        fi
    else
        echo "false"
    fi
}     

# check if a git repo exists in the directory
checkForGitDir()
{
    if [ "$(git -C $path rev-parse --abbrev-ref HEAD)" != "" ]; then
        echo "true"
    else
        echo "false"
    fi
}

# return branch name if there is one
getBranch()
{   
    if [ $(checkForGitDir) == "true" ]; then
        echo $(git -C $path rev-parse --abbrev-ref HEAD)
    else
        echo $no_repo_message
    fi
}

# return the final message for the status bar
getMessage()
{
    if [ $(checkForGitDir) == "true" ]; then
        branch="$(getBranch)"
        
        if [ $(checkForChanges) == "true" ]; then 
            
            changes="$(getChanges)" 
            
            if [ "${hide_status}" == "false" ]; then
                if [ $(checkEmptySymbol $diff_symbol) == "true" ]; then
                    echo "${changes} $branch"                    
                else
                    echo "$diff_symbol ${changes} $branch"
                fi
            else
                if [ $(checkEmptySymbol $diff_symbol) == "true" ]; then
                    echo "$branch"
                else
                    echo "$diff_symbol $branch"                    
                fi
            fi

        else
            if [ $(checkEmptySymbol $current_symbol) == "true" ]; then
                echo "$branch"
            else
                echo "$current_symbol $branch"
            fi
        fi
    else
        echo $no_repo_message
    fi
}

main()
{  
    path=$(getPaneDir)
    getMessage
}

#run main driver program
main 
