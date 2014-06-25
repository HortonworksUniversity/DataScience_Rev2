#!/bin/bash

/root/dockerfiles/start_scripts/build.sh


cd /root/$REPO_DIR
if [[ ! -z $FORCE ]];
then
  git reset HEAD --hard
fi
git pull

cd /root/dockerfiles
if [[ ! -z $FORCE ]];
then
  git reset HEAD --hard
fi
git pull

if [[ (-z $SKIP_IMAGES) || (! -z $FORCE) ]];
then

# Build the Docker images

# Build hwx/hdp_node_base first
cd /root/dockerfiles/hdp_node_base
x=$(docker images | grep -c  hwx/hdp_node_base)
if [ $x == 0 ]; then
        echo -e "\n*** Building hwx/hdp_node_base image... ***\n"
        docker build -t hwx/hdp_node_base .
        echo -e "Build of hwx/hdp_node_base complete!"
else
        echo -e "\n*** hwx/hdp_node_base image already built ***\n"
fi


# Build hwx/hdp_python_node
echo -e "\n*** Building hwx/hdp_python_node ***\n"
cd /root/$REPO_DIR/dockerfiles/hdp_python_node
docker build -t hwx/hdp_python_node .
echo -e "\n*** Build of hwx/hdp_python_node complete! ***\n"

# Build hwx/hdp_mahout_node
echo -e "\n*** Building hwx/hdp_mahout_node ***\n"
cd /root/$REPO_DIR/dockerfiles/hdp_mahout_node
docker build -t hwx/hdp_mahout_node .
echo -e "\n*** Build of hwx/hdp_mahout_node complete! ***\n"

# Build hwx/hdp_spark_node
echo -e "\n*** Building hwx/hdp_spark_node ***\n"
cd /root/$REPO_DIR/dockerfiles/hdp_spark_node
docker build -t hwx/hdp_spark_node .
echo -e "\n*** Build of hwx/hdp_spark_node complete! ***\n"

# Build hwx/ipython_node
echo -e "\n*** Building hwx/ipython_node ***\n"
cd /root/$REPO_DIR/dockerfiles/ipython_node
docker build -t hwx/ipython_node .
echo -e "\n*** Build of hwx/ipython_node complete! ***\n"

#If this script is execute multiple times, untagged images get left behind
#This command removes any untagged Docker images
docker rmi -f $(docker images | grep '^<none>' | awk '{print $3}')

fi

# Add/modify DS root directory in start scripts 
sed -i "/REPO_DIR=.*/c\REPO_DIR=/root/$REPO_DIR" /root/$REPO_DIR/scripts/ds_cluster.sh
sed -i "/REPO_DIR=.*/c\REPO_DIR=/root/$REPO_DIR" /root/$REPO_DIR/scripts/ds_ipython.sh
sed -i "/REPO_DIR=.*/c\REPO_DIR=/root/$REPO_DIR" /root/$REPO_DIR/scripts/ds_spark_cluster.sh


#Install python pip and the Python Avro library
apt-get -y --force-yes install python-pip
apt-get -y --force-yes install python-dateutil
pip install -U avro


#Enable syntax highlighting in nano
cp /etc/nanorc /root/.nanorc

echo -e "\n*** The lab environment has successfully been built for this classroom VM ***\n"
