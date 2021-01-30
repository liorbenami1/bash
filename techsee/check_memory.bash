#!/bin/bash

# this script measure the php master process every 5min
# and print the output to /home/bitnami/check_memory_output.csv file
# author: Lior Ben Ami
# applying to a devops position at techsee


# Define a timestamp function
timestamp() {
  date
}

export RAW=$(ps -o pid,user,%mem,command ax | grep php | grep master |grep -v PID | sort -bnr -k3 | awk '/[0-9]*/{print $1 ":" $2 ":" $4}')

# format title
printf "%-10s%-15s%-15s%-15s%-30s%s\n" "PID" ", OWNER" ", MEMORY" ", TIME" ", COMMAND" ", DESC" > /home/bitnami/check_memory_output.csv
while [  TRUE ]; do
	PID=$(echo $RAW | cut -d: -f1)
	OWNER=$(echo $RAW | cut -d: -f2)
	COMMAND=$(echo $RAW | cut -d: -f3)
	MEMORY=$(sudo pmap $PID | tail -n 1 | awk '{print $2}')
	TIMESTAMP=`timestamp`
	DESC=$(ps -ef | grep php | grep master | awk '{out=""; for(i=9;i<=NF;i++){out=out" "$i}; print out}')
	printf "$PID, $OWNER, $MEMORY, $TIMESTAMP, $COMMAND, $DESC\n" >> /home/bitnami/check_memory_output.csv
	sleep 5m
done
