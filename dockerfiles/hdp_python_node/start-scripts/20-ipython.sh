#!/bin/bash

source /etc/bashrc
/etc/init.d/sshd start

# The /root/nltk_data folder gets mapped to the Ubuntu host
mkdir -p /root/nltk_data

export HOME=/root
cd /root/notebooks
ipython notebook --profile=nbserver > /tmp/ipython.log 2>&1
#IPYTHON_OPTS="notebook --pylab inline --profile nbserver" /usr/lib/spark/bin/pyspark
