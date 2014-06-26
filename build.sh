#!/bin/bash

/root/dockerfiles/start_scripts/build.sh $1


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

# By default, the following Docker images are not rebuilt. 
# To rebuild these images, add a command-line argument named "rebuild"
REBUILD=
# Skip the building of images by default
if [[ ($2 == "rebuild") || ($3 == "rebuild") ]]; then
	REBUILD=true;
else
	REBUILD=false;
fi

if [[ $REBUILD  ]];
then

# Build the Docker images

# Build hwxu/hdp_node_base first
cd /root/dockerfiles/hdp_node_base
x=$(docker images | grep -c  hwxu/hdp_node_base)
if [ $x == 0 ]; then
        echo -e "\n*** Building hwxu/hdp_node_base image... ***\n"
        docker build -t hwxu/hdp_node_base .
        echo -e "Build of hwxu/hdp_node_base complete!"
else
        echo -e "\n*** hwxu/hdp_node_base image already built ***\n"
fi


# Build hwxu/hdp_python_node
echo -e "\n*** Building hwxu/hdp_python_node ***\n"
cd /root/$REPO_DIR/dockerfiles/hdp_python_node
docker build -t hwxu/hdp_python_node .
echo -e "\n*** Build of hwxu/hdp_python_node complete! ***\n"

# Build hwxu/hdp_mahout_node
echo -e "\n*** Building hwxu/hdp_mahout_node ***\n"
cd /root/$REPO_DIR/dockerfiles/hdp_mahout_node
docker build -t hwxu/hdp_mahout_node .
echo -e "\n*** Build of hwxu/hdp_mahout_node complete! ***\n"

# Build hwxu/hdp_spark_node
echo -e "\n*** Building hwxu/hdp_spark_node ***\n"
cd /root/$REPO_DIR/dockerfiles/hdp_spark_node
docker build -t hwxu/hdp_spark_node .
echo -e "\n*** Build of hwxu/hdp_spark_node complete! ***\n"

# Build hwxu/ipython_node
echo -e "\n*** Building hwxu/ipython_node ***\n"
cd /root/$REPO_DIR/dockerfiles/ipython_node
docker build -t hwxu/ipython_node .
echo -e "\n*** Build of hwxu/ipython_node complete! ***\n"

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
