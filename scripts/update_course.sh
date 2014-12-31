#!/bin/bash

pwd=$PWD
cd /root/ds
git pull origin --dry-run | grep -q -v 'Already up-to-date.' && changed=1
if [[ changed == 1 ]];
then
  old=`readlink /root/ds`
  cd /root
  ts=`date +"%Y%m%d-%H%M%S"`
  git clone https://github.com/HortonworksUniversity/DataScience_Rev2.git ds-$ts
  rm -f /root/ds
  ln -s /root/ds-$ts /root/ds
  cd /root/ds
  git checkout hdp22-sandbox
  echo "Course updated. Previous version lab files available in $old."
else
  echo "No updates found for course."
fi
cd $pwd
