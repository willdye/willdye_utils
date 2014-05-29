#!/usr/bin/env tclsh
# Demonstrate TCP messaging with TCL and Bash.  Requires sender and reciever.

set ::server_port 8756 # Any valid port number will do.

proc handler {channel address client_port} {
    puts "$channel $address $client_port : [string trim [gets $channel]]"
    close $channel ;# This means we only allow one line per message.
}
socket -server handler $::server_port
vwait forever
