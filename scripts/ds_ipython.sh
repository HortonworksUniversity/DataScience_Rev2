#!/bin/bash

echo "Starting IPython Notebook Node..."
CID_ipython=$(docker run -d -v /root/notebooks:/root/notebooks -v /root/nltk_data:/root/nltk_data --privileged --dns 8.8.8.8 -p 8888:8888 -p 22 --name ipython -h ipython -i -t hwxu/ipython_node bash)
IP_ipython=$(docker inspect --format "{{ .NetworkSettings.IPAddress }}" ipython)
IP=$(/sbin/ifconfig eth0 | grep 'inet addr:' | cut -d: -f2 | awk '{ print $1}')
echo "IPython Notebook Server Started at http://$IP:8888/ (ssh IP is $IP_ipython)"
