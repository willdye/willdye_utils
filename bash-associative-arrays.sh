#!/bin/bash
# Simple demonstration of associative arrays in Bash.
# When I was your age, ya young millenial whippersnappers...

declare -A incline=([home]=uphill [school]=uphill [Applebees]=uphill)

for i in home school home applebees home
do echo "Walk ${incline[$i]} to $i."
done

# Expected output:
#
#     Walk uphill to home.
#     Walk uphill to school.
#     Walk uphill to home.
#     Walk uphill to Applebees.
#     Walk uphill to home.
