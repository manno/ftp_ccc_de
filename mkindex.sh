#!/bin/bash
# run as ftp user

PATH=/usr/bin:/bin
umask 022

MAILTO="ftpmaster"

BASEDIR="/srv/ftp"
USER="ftp"
GROUP="uploaders"

cd $BASEDIR && find . -type f -printf "%T@ %s %p\n" | sort -n | gzip -1 > INDEX.gz
chown "${USER}:${GROUP}" INDEX.gz
