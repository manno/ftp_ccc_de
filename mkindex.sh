#!/bin/bash
#set -x

PATH=/usr/bin:/bin
umask 022

MAILTO="ftpmaster"

BASEDIR="/srv/ftp"
USER="ftp"
GROUP="uploaders"

cd $BASEDIR && find . -type f -printf "%s %T@ %p\n" | sort | gzip -1 > INDEX.gz
chown "${USER}:${GROUP}" INDEX.gz
