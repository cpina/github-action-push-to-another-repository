#!/bin/sh -l

set -euo pipefile

rc=0
for filename in $(find ./* -name '*.sh'); do
  echo "Validating"
  shellcheck "${filename}" || exit $?
done

exit $?