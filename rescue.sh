#!/bin/bash

VERSION='0.01'
RELEASE_DATE='2023-01-15'
COMMIT_DATE=''

## Check if the script is run with bash as shell interpreter.
if [ -z "$BASH_VERSION" ]; then
  echo 'Script needs to be run with bash as shell interpreter.' >&2
  exit 1
fi

## Display version, release, last git commit and git retrieval date of the script when asked: ##
#
#   ./rescue.sh -v
#   ./rescue.sh --version

log() {
  echo "$1"
  read -r -p "Press enter to continue"
}

version() {
  printf '\nScript version: %s\n  Release date: %s' "${VERSION}" "${RELEASE_DATE}"

  if [[ -n "${COMMIT_DATE}" ]]; then
    printf '\n  Commit date: %s' "${COMMIT_DATE}"
  fi

  printf '\n\n'
  exit 0
}

## Display help text ##
#
#   ./rescue.sh -h
#   ./rescue.sh --help

help() {
  cat <<HELP

----------------------------------------------------------------------------------------------------
Usage:
----------------------------------------------------------------------------------------------------
Run the script as sudoer:

  sudo ${0} [options] [parameters]

or if your operating system does not use sudo:

  su -
  ${0} [options] [parameters]

To get version number, release date, last git commit and git retrieval date, with:

  ${0} -v
  ${0} --version

To get this help text, with:

  ${0} -h
  ${0} --help

The last development version of Script can be downloaded, with:

  ${0} -u
  ${0} --update

HELP
}

## Download the last version from git: ##
#
#   ./rescue.sh -u
#   ./rescue.sh --update
#

update() {
  local git_ref_url='https://api.github.com/repos/ddwin/rescue/git/refs/heads/main'
  local git_commit_url='https://api.github.com/repos/ddwin/rescue/git/commits'
  local git_contents_url='https://github.com/ddwin/rescue/raw/main/rescue.sh'

  # Check if date is available.
  if [[ $(type date echo $? >/dev/null 2>&1) -ne 0 ]]; then
    echo '"date" could not be found.' >&2
    exit 1
  fi

  # Get current UTC time in YYYY-MM-DD_hh:mm:ss format.
  UTC_TIME=$(date --utc "+%Y-%m-%d_%T")
  log "${UTC_TIME}"
  FILENAME="${HOME}/rescue_${UTC_TIME}.sh"
  log "${FILENAME}"

  # Check if wget or curl is available
  if [[ $(type wget echo $? >/dev/null 2>&1) -eq 0 ]]; then
    printf '\nDownloading last development version of Script from git:\n\n'
    LAST_GIT_COMMIT_ID=$(wget -O - "${git_ref_url}" | sed -ne 's/^.*"sha": "\(.*\)".*$/\1/p')
    log "${LAST_GIT_COMMIT_ID}"
    LAST_GIT_COMMIT=$(wget -O - "${git_commit_url}/$LAST_GIT_COMMIT_ID")
    log "${LAST_GIT_COMMIT}"

    wget -O "${FILENAME}" "${git_contents_url}"
  elif [[ $(type curl echo $? >/dev/null 2>&1) -eq 0 ]]; then
    printf 'Downloading last development version of Script from git:\n\n'
    LAST_GIT_COMMIT_ID=$(curl "${git_ref_url}" | sed -ne 's/^.*"sha": "\(.*\)".*$/\1/p')
    LAST_GIT_COMMIT=$(curl "${git_commit_url}/$LAST_GIT_COMMIT_ID")

    curl -o "${FILENAME}" "${git_contents_url}"
  else
    printf '"wget" or "curl" could not be found.\nInstall at least one of them and try again.\n' >&2
    exit 1
  fi

  # First date is Author, second date is Commit
  COMMIT_DATE=$(echo "${LAST_GIT_COMMIT}" | sed -ne 's/^[[:space:]]*"date": "\(.*\)"[[:space:]]*$/\1/p' | tail -1)
  log "${COMMIT_DATE}"

  # Set the retrieval date in just downloaded script.
  sed -i -e "5,0 s/COMMIT_DATE='';/COMMIT_DATE='${COMMIT_DATE}';/" "${FILENAME}"

  printf '\nThe development version of Script is saved as:\n"%s"\n\n' "${FILENAME}"
  exit 0
}

## Get arguments passed to the script. ##

process_args() {
  if [[ ${#@} -ge 1 ]]; then
    # Process arguments.
    case "$1" in
    -h) help ;;
    --help) help ;;
    -u) update ;;
    --update) update ;;
    -v) version ;;
    --version) version ;;
    -*) help ;;
    *) ;;
    esac
  fi
}

## Get arguments passed to the script. ##

process_args "${@}"

exit 0
