#!/bin/bash
# Description: Sync from master.
# Stops working after the first error, unless using -c

rsync=/usr/bin/rsync
LOCK_FILE=/var/tmp/rsync-media.lock
MASTER=upload.media.ccc.de

usage () {
  cat << EOF
  usage: $0 [-f][-v]
    -f      force, remove lock file first
    -v      verbose, direct output to stdout
EOF
  exit
}

while getopts "fvh" opt; do
  case "$opt" in 
    v) VERBOSE=1;;
    f) rm -f "$LOCK_FILE";;
    *) usage;;
  esac
done

# CRON: silent unless VERBOSE
if [ -z "$VERBOSE" ]; then
  MAILTO=""
  exec >/dev/null 2>&1
fi

if [ -f "$LOCK_FILE" ]; then
  /usr/bin/logger -t "$(basename $0)[$$]" "Lock file '${LOCK_FILE}' exists. Please check if another rsync is running. Test sync: 'sudo -u media-sync $0 -fv'"
  exit
fi

# start sync
echo "create lock file"
touch "$LOCK_FILE"

echo "sync /srv/ftp from master"
$rsync --bwlimit=10240 -Pa -x --delete --exclude "lost+found" --exclude INDEX.gz ${MASTER}:/srv/ftp/ /srv/ftp 

# cleanup
echo "remove lock file"
rm -f "$LOCK_FILE"
