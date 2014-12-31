#!/bin/bash

if [[ ! -f '/tmp/pyspark.pid' ]];
then
  echo "No PID file found for IPython PySpark Notebook...terminating"
  exit -1;
fi

cat /tmp/pyspark.pid | xargs kill

echo "Killed PID `cat /tmp/pyspark.pid`"
rm /tmp/pyspark.pid
