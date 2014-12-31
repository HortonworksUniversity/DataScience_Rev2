#!/bin/bash

set -x

exec > /tmp/ds_uninstall.log 2>&1 

cp /etc/bashrc.beforeds /etc/bashrc
cp /etc/profile.beforeds /etc/profile

rm -rf /anaconda
rm -rf /usr/lib/spark
rm -rf /root/nltk_data

gem uninstall sinatra 
gem uninstall fastercsv
#gem uninstall json

