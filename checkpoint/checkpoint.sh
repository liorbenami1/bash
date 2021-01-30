
#!/bin/bash

# This script:
# 1) Scan a given log directory
# 2) Search for all files that have extention of: *.log*
#    For example: access.log
#                 access.log1
#                 error.log
#                 error.log7 
# 3) rename all log files to <log file>.log<incriment index>
# 4) touch a new file name with no extention (touch access.log error.log)
# 5) delete all files with index equal or gretter then $MAX (set ot 10)
#
# Usage: run this script with parameter of the log directory path
# Autor: Lior Ben Ami
# Date: Jan 2021
# As part of CheckPoint Assignment


main() {
    # the the input directory and assign file list to array
    IFS=' ' read -r -a array <<< $(ls $log_dir)

    declare -A files_types
    for file in "${array[@]}"
    do
        #echo $file
        NAME=`echo "$file" | cut -d'.' -f1`
        EXTENSION=`echo "$file" | cut -d'.' -f2`
        EXTENSION+=" "
        #echo $NAME
        #echo $EXTENSION
        #Add only *.log* files
        if [[ $EXTENSION =~ "log" ]]; then
            files_types[$NAME]+=$EXTENSION
        fi
    done

    echo "${bold}Going to change the following files:${normal}"
    echo "${bold}-----------------------------------${normal}"
    print_log_dir
    echo "${bold}-----------------------------------${normal}"
    scan
}

print_log_dir() {
    for key in "${!files_types[@]}"; do
        for vals in "${files_types[$key]}"; do
            echo ""
            echo "${bold}$key files:${normal}"
            #echo "$key files:"
            for val in $vals; do
                echo "  - $key.$val"
            done
        done
    done
}

reverse() {
    declare -n arr=$1
    min=0
    max=$(( ${#arr[@]} -1 ))
    REVERSE=[]
    echo "reverse().input = ${arr[@]}"

    while [[ min -lt max ]]; do
        # Swap current first and last elements
        x="${arr[$min]}"
        arr[$min]="${arr[$max]}"
        arr[$max]="$x"

        # Move closer
        (( min++, max-- ))
    done

    REVERSE=`echo ${arr[@]}`
    echo "reverse().output = ${REVERSE[@]}"
}

remane_log_files() {
    #echo "rename().starting..."
    declare -n type=$1
    extention="log"
    for old_index in $REVERSE; do
        if [[ $old_index == "0" ]]; then
            old_index=""
        fi
        old_name=${log_dir}/${type}.${extention}$old_index
        if [[ $old_index -ge $MAX ]]; then
            echo "${bold}${red}${white}rm $old_name${normal}"
            rm $old_name
            continue
        fi
        new_index="$(($old_index + 1))"
        new_name=${log_dir}/${type}.${extention}$new_index
        echo "mv $old_name $new_name"
        mv $old_name $new_name
    done
    echo "touch ${log_dir}/${type}.${extention}"
    touch ${log_dir}/${type}.${extention}
}

scan() {
for key in "${!files_types[@]}"; do
    for vals in "${files_types[$key]}"; do
            indexes=()
            for val in $vals; do
                if [[ $val == "log" ]]; then
                    val=0
                fi 
                #append new index to array
                indexes=("${indexes[@]}" `echo $val | sed -e 's/log//g'`)
            done
            reverse indexes
            remane_log_files key
    done
done
}

bold=$(tput bold)
normal=$(tput sgr0)
red=`tput setaf 1`
#define white background
white=`tput setab 7`
# Check for input parameter:
if [[ $# -eq 0 ]] ; then
    echo "${bold}Please specify a log dir to scan. ${red}Abort.${normal}"
    exit 1
fi
# Input 
log_dir=$1
REVERSE=[]
MAX=10


#call main function
main $log_dir


#TABLE for tput setaf & setap:
#https://stackoverflow.com/questions/5947742/how-to-change-the-output-color-of-echo-in-linux?noredirect=1&lq=1
#Num  Colour    #define         R G B
#
#0    black     COLOR_BLACK     0,0,0
#1    red       COLOR_RED       1,0,0
#2    green     COLOR_GREEN     0,1,0
#3    yellow    COLOR_YELLOW    1,1,0
#4    blue      COLOR_BLUE      0,0,1
#5    magenta   COLOR_MAGENTA   1,0,1
#6    cyan      COLOR_CYAN      0,1,1
#7    white     COLOR_WHITE     1,1,1


