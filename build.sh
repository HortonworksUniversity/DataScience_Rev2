#!/bin/bash
# If you want to rebuild just the Docker images in this file, then add the "rebuild" argument to the command line
# For example:
# root@ubuntu:~# ./install_course.sh DataScience_Rev2 rebuild

var1=$1  #DataScience_RevN
var2=$2  #rebuild (optionally rebuild the Docker images)
var3=$3

/root/dockerfiles/start_scripts/build.sh $var1 skip-images
export REPO_DIR=$var1

# Rebuild hwxu/hdp_node to make sure students have a fix to the timeline server start script
echo -e "\n*** Building hwxu/hdp_node ***\n"
cd /root/dockerfiles/hdp_node
docker build -t hwxu/hdp_node .
echo -e "\n*** Build of hwxu/hdp_node complete! ***\n"

cp /root/dockerfiles/hdp_node/configuration_files/core_hadoop/yarn-site.xml /etc/hadoop/conf

#If this script is execute multiple times, untagged images get left behind
#This command removes any untagged Docker images
docker rmi -f $(docker images | grep '^<none>' | awk '{print $3}')

cd /root/$REPO_DIR
if [[ ! -z $FORCE ]];
then
  git reset HEAD --hard
fi
git pull

cd /root/dockerfiles
#Temporary - remove any local edits in the dockerfiles project folder
git reset HEAD --hard
if [[ ! -z $FORCE ]];
then
  git reset HEAD --hard
fi
git pull

# By default, the following Docker images are not rebuilt. 
# To rebuild these images, add a command-line argument named "rebuild"
REBUILD=
if [[ ($var2 == "rebuild") || ($var3 == "rebuild") ]]; then
	REBUILD=true;
fi

if [[ $REBUILD == true  ]];
then
	echo -e "NOTE: Rebuilding Data Science Docker images..."

        # Build the Docker images
        # Build hwxu/hdp_anaconda_node
        echo -e "\n*** Building hwxu/hdp_anaconda_node ***\n"
        cd /root/$REPO_DIR/dockerfiles/hdp_anaconda_node
        docker build -t hwxu/hdp_anaconda_node .
        echo -e "\n*** Build of hwxu/hdp_anaconda_node complete! ***\n"

	# Build the Docker images
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

#install graphviz (for the dot command to work in the DecisionTree demo)
apt-get -y --force-yes install graphviz

#Enable syntax highlighting in nano
cp /etc/nanorc /root/.nanorc

#Copy pre-built notebooks into /root/notebooks
mkdir -p /root/notebooks
cp -r /root/$REPO_DIR/dockerfiles/hdp_python_node/notebooks/* /root/notebooks/

#The NLTK toolkit saves downloaded content here:
mkdir -p /root/nltk_data

echo -e "\n*** The lab environment has successfully been built for this classroom VM ***\n"
