#!/bin/bash

/etc/init.d/sshd start
export HOME=/root
cd /root/notebooks
ipython notebook --profile=nbserver > /tmp/ipython.log 2>&1
