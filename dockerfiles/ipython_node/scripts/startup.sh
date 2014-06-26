#!/bin/bash

source /etc/bashrc
/etc/init.d/sshd start
export HOME=/root
ipython notebook --profile=nbserver > /tmp/ipython.log 2>&1
