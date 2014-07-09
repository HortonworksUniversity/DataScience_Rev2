#!/bin/bash


# The /root/nltk_data folder gets mapped to the Ubuntu host
mkdir -p /root/nltk_data

export HOME=/root
cd /root/notebooks
IPYTHON_OPTS="notebook --pylab inline --profile nbserver --port 9999" /usr/lib/spark/bin/pyspark
