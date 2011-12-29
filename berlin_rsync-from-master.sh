#!/bin/bash
# Description: Sync from master.
# Stops working after the first error, unless using -c
rsync=/usr/bin/rsync
LOCK_FILE=/var/tmp/rsync-media.lock
MASTER=koeln.media.ccc.de

usage () {
  cat << EOF
  usage: $0 [-f][-c][-v]
    -f      force, remove lock file first
    -c      cleanup, always remove lock file
    -v      verbose, direct output to stdout
EOF
  exit
}

while getopts "fvhc" opt; do
  case "$opt" in 
    v) VERBOSE=1;;
    c) CLEANUP=1;;
    f) rm "$LOCK_FILE";;
    *) usage;;
  esac
done

# CRON: silent unless VERBOSE
if [ -z "$VERBOSE" ]; then
  MAILTO=""
  exec >/dev/null 2>&1
fi

# always delete lock file
if [ "$CLEANUP" ]; then
  # untested
  trap "rm -f $LOCK_FILE; exit $?" 0 1 2 3 15
fi

# exit on error
set -e

if [ -f "$LOCK_FILE" ]; then
  /usr/bin/logger -t "$(basename $0)[$$]" "Lock file '${LOCK_FILE}' exists. Please check if another rsync is running. Test sync: 'sudo -u media-sync $0 -fv'"
  exit
fi

# start sync
echo "create lock file"
touch "$LOCK_FILE"

echo "sync /srv/ftp from master"
$rsync --bwlimit=10240 -Pa -x --delete --exclude "lost+found" --exclude "INDEX.gz" ${MASTER}:/srv/ftp/ /srv/ftp 
echo "sync /srv/www from master"
$rsync -Pa -x --delete --exclude "mrtg" ${MASTER}:/srv/www/media.koeln.ccc.de/ /srv/www/media.koeln.ccc.de

echo "remove lock file"
rm "$LOCK_FILE"
