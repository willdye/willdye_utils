#!/bin/bash
# sleepsort: If you think this is a *complete* joke, you don't grok Hadoop.

echo "Sorts parameter list.  Input values must be single positive digits."

check() { [[ "$1" =~ ^[0-9]$ ]] || { echo "Invalid: $1"; return 1; }; }
map()   { sleep "$1"; echo "$1"; }
reduce(){ wait; }

for i in "$@"
do check "$i" && map "$i" &
done

reduce

# An even shorter version:
#  for i in "$@"; do [[ $i =~ ^[0-9]$ ]] && sleep $i && echo $i & done; wait
