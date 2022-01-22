#!/bin/sh
# shellcheck disable=SC2044

set -eu pipefile

rc=0
for filename in $(find ./* -name '*.sh'); do
  echo "Start to validating ${filename}"
  shellcheck "${filename}" || exit $?
  echo "🚀Successfully Validated ${filename}"
done

exit $rc