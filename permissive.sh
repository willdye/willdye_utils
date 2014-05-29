#!/bin/bash
# Recursively chmod every specified directory and file such that anyone in
# the group has full read/write/execute permissions.  Whenever practical,
# do NOT use this on large network-mounted directories.

BATCH_ECHO=${BATCH_ECHO:-""} # For a dry-run test: export BATCH_ECHO="echo"

fix_next_file() {
  for i in "${@}"
  do
    # Certain filename extensions indicate that the file should probably be
    # executable.  Exceptions happen, but should be rare in at-dd test data.
    case "${i}" in
      *.bat)  $BATCH_ECHO chmod --quiet ug+rwx "${i}" ;;
      *.exe)  $BATCH_ECHO chmod --quiet ug+rwx "${i}" ;;
      *.sh)   $BATCH_ECHO chmod --quiet ug+rwx "${i}" ;;
      *)      $BATCH_ECHO chmod --quiet ug+rwX "${i}" ;; # Note capital X.
    esac
  done
}

export -f fix_next_file # This allows the function to be called by xargs.

for i in "${@}"
do
  if [[ -d "$i" ]]
  then
    # Fix directories first, to ensure that subsequent scans can recurse.
    # Attempts to do everything in a single pass of 'find' ran into some
    # problems in certain rare cases, especialy on older OS versions, but
    # it might still be possible.  If you try it, test the code carefully.
    find "$i" -user $(whoami) -type d -print0 |
    xargs -0rn1 $BATCH_ECHO chmod --quiet 2775

    # If you change this section, be sure to test your code using filenames
    # with unusual characters like "&" and "(".  Quoting can be tricky here.
    find "$i" -user $(whoami) -type f -print0 |
    xargs -0rn1 -i bash -c "fix_next_file \"{}\""
  else
    [[ -f "$i" ]] && fix_next_file "$i"
  fi
done
