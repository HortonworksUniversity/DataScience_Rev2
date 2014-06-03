#!/bin/bash

if [[ -z $1 ]];
then
  echo "Usage: $0 <class_version> [force|skip-images]"
  exit 1;
fi

SKIP_IMAGES=
FORCE=
if [ $2 == "force" ]; then
  FORCE=true
  echo "NOTE: Rebuilding classroom environment, removing any local changes..."
elif [ $2 == "skip-images" ]; then
  SKIP_IMAGES=true
  echo "NOTE: Skipping Docker image file updates..."
fi

DS_DIR=$1

cd /root/$DS_DIR
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

# Build hwx/hdp_node
echo -e "\n*** Building hwx/hdp_node ***\n"
cd /root/dockerfiles/hdp_node
docker build -t hwx/hdp_node .
echo -e "\n*** Build of hwx/hdp_node complete! ***\n"

# Build hwx/hdp_python_node
echo -e "\n*** Building hwx/hdp_python_node ***\n"
cd /root/$DS_DIR/dockerfiles/hdp_python_node
docker build -t hwx/hdp_python_node .
echo -e "\n*** Build of hwx/hdp_python_node complete! ***\n"

# Build hwx/hdp_mahout_node
echo -e "\n*** Building hwx/hdp_mahout_node ***\n"
cd /root/$DS_DIR/dockerfiles/hdp_mahout_node
docker build -t hwx/hdp_mahout_node .
echo -e "\n*** Build of hwx/hdp_mahout_node complete! ***\n"

# Build hwx/hdp_spark_node
#echo -e "\n*** Building hwx/hdp_spark_node ***\n"
#cd /root/$DS_DIR/dockerfiles/hdp_spark_node
#docker build -t hwx/hdp_spark_node .
#echo -e "\n*** Build of hwx/hdp_spark_node complete! ***\n"

# Build hwx/ipython_node
echo -e "\n*** Building hwx/ipython_node ***\n"
cd /root/$DS_DIR/dockerfiles/ipython_node
docker build -t hwx/ipython_node .
echo -e "\n*** Build of hwx/ipython_node complete! ***\n"

#If this script is execute multiple times, untagged images get left behind
#This command removes any untagged Docker images
docker rmi -f $(docker images | grep '^<none>' | awk '{print $3}')

fi

# Add/modify DS root directory in start scripts 
sed -i "/DS_DIR=.*/c\DS_DIR=/root/$DS_DIR" /root/$DS_DIR/scripts/ds_cluster.sh
sed -i "/DS_DIR=.*/c\DS_DIR=/root/$DS_DIR" /root/$DS_DIR/scripts/ds_ipython.sh
sed -i "/DS_DIR=.*/c\DS_DIR=/root/$DS_DIR" /root/$DS_DIR/scripts/ds_spark_cluster.sh

# Copy utility scripts into /root/scripts, which is already in the PATH
echo "Copying utility scripts..."
cp /root/dockerfiles/start_scripts/* /root/scripts/
cp /root/$DS_DIR/scripts/* /root/scripts/


cp /root/dockerfiles/hdp_node/configuration_files/core_hadoop/* /etc/hadoop/conf/

#Replace /etc/hosts with one that contains the Docker server names
cp /root/scripts/hosts /etc/

#Install python pip and the Python Avro library
apt-get -y --force-yes install python-pip
apt-get -y --force-yes install python-dateutil
pip install -U avro


#Update hadoop-env.sh to allocate more memory for local tasks
#cp /root/$DS_DIR/hadoop2.4/hadoop-env.sh /etc/hadoop/conf

#Enable syntax highlighting in nano
cp /etc/nanorc /root/.nanorc

echo -e "\n*** The lab environment has successfully been built for this classroom VM ***\n"
