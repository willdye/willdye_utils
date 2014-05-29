#!/bin/bash
# Demonstrate TCP messaging with TCL and Bash.  Requires sender and reciever.

server_port=8756 # Any valid port number will do.

where=${1:-"$(hostname)"}
port=${2:-"$server_port"}

while sleep 3
do date +"$(hostname) : %X" > /dev/tcp/$where/$port
done
