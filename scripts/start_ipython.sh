#!/bin/bash

ipython notebook --profile=nbserver --port 11111 --notebook-dir=/root/ds/labs/notebooks > /tmp/ipython.log 2>&1 &
echo $! > /tmp/ipython.pid

