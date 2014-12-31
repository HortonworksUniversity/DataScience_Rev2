#!/bin/bash

if [[ ! -f '/tmp/ipython.pid' ]];
then
  echo "No PID file found for IPython Notebook...terminating"
  exit -1;
fi

cat /tmp/ipython.pid | xargs kill

echo "Killed PID `cat /tmp/ipython.pid`"
rm /tmp/ipython.pid
