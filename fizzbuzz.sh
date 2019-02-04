#!/bin/bash
# Bash version of the (in)famous "FizzBuzz" test.

# Fizzbuzz in 75 characters of Bash.
for i in {1..100};do((i%3))&&x=||x=Fizz;((i%5))||x+=Buzz;echo ${x:-$i};done

echo ==========================

# This is the same as the concise version above, but expanded for readability.
for i in {1..100}
do  (( i % 3 )) && x= || x=Fizz
    (( i % 5 )) || x+=Buzz
    echo ${x:-$i}
done |
column # The pipe to "column" isn't required by the test; it's just cosmetic.

echo ==========================

# The concise version, expanded to multiple lines, with verbose comments.
for i in {1..100} # Use i to loop from "1" to "100", inclusive.
do  ((i % 3)) &&  # If i is not divisible by 3...
        x= ||     # ...blank out x (yes, "x= " does that).  Otherwise,...
        x=Fizz    # ...set x to the string "Fizz".
    ((i % 5)) ||  # If i is not divisible by 5, skip (there's no "&&")...
        x+=Buzz   # ...Otherwise, append (not set) the string "Buzz" to x.
   echo ${x:-$i}  # Print x unless it is blanked out.  Otherwise, print i.
done | column     # Wrap output into columns (not part of the test).

echo ==========================

# If allowed, prettify the output a bit:
for i in {1..100}
do  x=""
    (( i % 3 )) || x+="Fizz"
    (( i % 5 )) || x+="Buzz"
    [[ $x ]] && f="%8s" || f="%8d"
    printf " %3d: $f\n" "$i" "${x:-$i}"
done | column

exit

echo ==========================

# Or maybe just:
for i in {1..100} ;
do  !((i % 3)) &&  x="Fizz" || x= ;
    !((i % 5)) && x+="Buzz" ;
    echo "${x:-$i}" ;
done | column ;

echo ==========================

# Or maybe just:
for i in {1..100} ;
do  x=
    ((i % 3)) || x+="Fizz" ;
    ((i % 5)) || x+="Buzz" ;
    echo "${x:-$i}" ;
done | column ;

echo ==========================

# Or maybe just:
for i in {1..100}
do  (( i % 3 )) && x="" || x="Fizz"
    (( i % 5 )) || x+="Buzz"
    echo "${x:-$i}"
done | column

echo ==========================

# Single-line (75-char) version:
for i in {1..100};do((i%3))&&x=||x=Fizz;((i%5))||x+=Buzz;echo ${x:-$i};done|column
