#!/bin/bash

#TODO: Improve this script to only clone the repo when changes actually exist since the last update

pwd=$PWD
cd /root/ds
old=`readlink /root/ds`
cd /root
ts=`date +"%Y%m%d-%H%M%S"`
git clone https://github.com/HortonworksUniversity/DataScience_Rev2.git ds-$ts
rm -f /root/ds
ln -s /root/ds-$ts /root/ds
cd /root/ds
git checkout hdp22-sandbox
echo "Course updated. Previous version lab files available in $old."
cd $pwd
