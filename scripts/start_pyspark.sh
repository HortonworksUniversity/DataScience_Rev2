#!/bin/bash

IPYTHON_OPTS="notebook --pylab inline --profile nbserver --port 22222 --notebook-dir=/root/ds/labs/notebooks" /usr/lib/spark/bin/pyspark > /tmp/pyspark.log 2>&1 &
echo $! > /tmp/pyspark.pid
