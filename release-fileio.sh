#!/usr/bin/env bash

# make it robust for running as a cron job
AWK=/usr/bin/awk
GIT=/usr/bin/git
GREP=/usr/bin/grep
LS=/usr/bin/ls
MAIL=/usr/bin/mail
RSYNC=/opt/cluster/external/utilities/bin64/rsync
ZIP=/usr/bin/zip

MODULE=$(basename $0 .sh | sed 's/release-\(.*\)/\1/')
BASEDIR=$HOME/fieldtrip/release
TRUNK=$BASEDIR/fieldtrip
MD5FILE=$BASEDIR/.tarmd5-release-$MODULE

cd $TRUNK && git checkout release && git pull upstream release

# TODAY=$(date +%Y%m%d)
# TODAY=$(git log -1 --format=%cd --date=format:%Y%m%d)
TODAY=$(git log -1 --format=%cd --date=short | tr -d -)

cd $BASEDIR || exit 1
$RSYNC -ar --copy-links --delete --exclude .git --exclude test $TRUNK/$MODULE/ release-$MODULE || exit 1

CURRMD5=$(tar cf - release-$MODULE |md5sum |awk '{print $1}')
LASTMD5=$(cat $MD5FILE)
if [[ "x$CURRMD5" = "x$LASTMD5" ]]
then
  # the current release has not been updated compared to the previous
  exit 0
else
  # the current release is an updated version
  echo $CURRMD5 > $MD5FILE
  mv release-$MODULE $MODULE-$TODAY
  $ZIP -r daily/$MODULE-$TODAY.zip $MODULE-$TODAY
  mv $MODULE-$TODAY release-$MODULE
	
  cp daily/$MODULE-$TODAY.zip /home/common/matlab/fieldtrip/data/ftp/modules
fi
