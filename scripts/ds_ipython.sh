#!/bin/bash
DS_DIR=/root/DataScience_Rev1

echo "Starting IPython Notebook Node..."
CID_ipython=$(docker run -d -v $DS_DIR/dockerfiles/ipython_node/notebooks:/root/notebooks --privileged --dns 8.8.8.8 -p 8888:8888 --name ipython -h ipython -i -t hwx/ipython_node)
IP_ipython=$(docker inspect --format "{{ .NetworkSettings.IPAddress }}" ipython)
IP=$(/sbin/ifconfig eth0 | grep 'inet addr:' | cut -d: -f2 | awk '{ print $1}')
echo "IPython Notebook Server Started at http://$IP:8888/ (ssh IP is $IP_ipython)"
