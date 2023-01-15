#!/bin/bash

VERSION='0.01'
RELEASE_DATE='2023-01-15'
LAST_GIT_COMMIT_DATE=''
LAST_GIT_COMMIT_SHORTLOG=''

## Check if the script is run with bash as shell interpreter.
if [ -z "$BASH_VERSION" ]; then
  echo 'Script needs to be run with bash as shell interpreter.' >&2
  exit 1
fi

## Display version, release, last git commit and git retrieval date of the script when asked: ##
#
#   ./rescue.sh -V
#   ./rescue.sh --version

version() {
  printf '\nScript version: %s\n  Release date: %s' "${VERSION}" "${RELEASE_DATE}"

  if [[ -n "${LAST_GIT_COMMIT_SHORTLOG}" ]]; then
    printf '\n   Last commit: %s\n     Commit date: %s' \
      "${LAST_GIT_COMMIT_SHORTLOG}" "${LAST_GIT_COMMIT_DATE}"
  fi

  printf '\n\n'
  exit 0
}
