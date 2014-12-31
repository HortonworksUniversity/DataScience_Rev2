#!/bin/bash

set -x

exec > /tmp/ds_install.log 2>&1 

echo "Backing up /etc/bashrc and /etc/profile..."
cp /etc/bashrc /etc/bashrc.beforeds
cp /etc/profile /etc/profile.beforeds

echo "Installing Anaconda..."
wget http://09c8d0b2229f813c1b93-c95ac804525aac4b6dba79b00b39d1d3.r79.cf1.rackcdn.com/Anaconda-2.1.0-Linux-x86_64.sh
bash Anaconda-2.1.0-Linux-x86_64.sh -b -p /anaconda
rm -f Anaconda-2.1.0-Linux-x86_64.sh
echo "export PATH=\"/anaconda/bin:\$PATH\"" >> /etc/bashrc
echo "export PATH=\"/anaconda/bin:\$PATH\"" >> /etc/profile
source /etc/bashrc
/anaconda/bin/ipython profile create nbserver
/anaconda/bin/conda update --yes ipython
/anaconda/bin/conda update --yes conda

echo "Copying Avro mapreduce library into Hadoop client classpath..."
cp /usr/hdp/current/sqoop-client/lib/avro-mapred-1.7.5-hadoop2.jar /usr/hdp/current/hadoop-client/lib

echo "Configuring IPython Notebook..."
cp -r conf/ipython_notebook_config.py /root/.ipython/profile_nbserver
mkdir -p /root/.config/matplotlib
echo "backend: Agg" > /root/.config/matplotlib/matplotlibrc

echo "Installing Avro CLI..."
/anaconda/bin/pip install avro

echo "Installing gcc-gfortran for Spark MLLib..."

yum -y install gcc-gfortran --enablerepo=updates

echo "Installing Spark 1.2.0 Technical Preview for HDP 2.2..."
wget http://s3.amazonaws.com/public-repo-1.hortonworks.com/HDP-LABS/Projects/spark/1.2.0/spark-1.2.0.2.2.0.0-82-bin-2.6.0.2.2.0.0-2041.tgz -O /tmp/spark.tgz
tar -C /usr/lib -zxvf /tmp/spark.tgz
ln -s /usr/lib/spark-1.2.0.2.2.0.0-82-bin-2.6.0.2.2.0.0-2041/ /usr/lib/spark
rm -f /tmp/spark.tgz
# Set environment variables needed to run Spark on YARN
echo "export YARN_CONF_DIR=/etc/hadoop/conf" >> /etc/bashrc
echo "export SPARK_WORKER_MEMORY=512m" >> /etc/bashrc
echo "export SPARK_MASTER_MEMORY=512m" >> /etc/bashrc
echo "export MASTER=yarn-client" >> /etc/bashrc
echo "export SPARK_HOME=/usr/lib/spark" >> /etc/bashrc
echo "export PYTHONPATH=\$SPARK_HOME/python/:\$PYTHONPATH" >> /etc/bashrc
echo "export PYTHONPATH=\$SPARK_HOME/python/lib/py4j-0.8.1-src.zip:\$PYTHONPATH" >> /etc/bashrc
echo "export SPARK_YARN_USER_ENV=\"PYTHONPATH=/usr/lib/spark/python/lib/py4j-0.8.1-src.zip:/usr/lib/spark/python/:\$PYTHONPATH\"" >> /etc/bashrc
echo "export PYSPARK_PYTHON=/anaconda/bin/python" >> /etc/bashrc
echo "export PATH=\$PATH:/usr/lib/spark/bin" >> /etc/bashrc
echo "spark.driver.extraJavaOptions    -Dhdp.version=2.2.0.0-2041" > /usr/lib/spark/conf/spark-defaults.conf
echo "spark.yarn.am.extraJavaOptions   -Dhdp.version=2.2.0.0-2041" >> /usr/lib/spark/conf/spark-defaults.conf

echo "Installing Mahout and dependencies for Mahout -p /anaconda labs..."
yum -y install mahout
# Install base Ruby packages for web front end used in Mahout lab
yum -y install gcc gcc-c++ ruby ruby-devel rubygems
# Install additional Ruby gems needed by web front end for Mahout lab
gem install sinatra --no-ri --no-rdoc
gem install fastercsv --no-ri --no-rdoc
gem install json --no-ri --no-rdoc

echo "Installing some additional dependencies for labs..."
yum -y install graphviz
/anaconda/bin/pip install python-dateutil
mkdir -p /root/nltk_data
yum -y install nano vim
cp /etc/nanorc /root/.nanorc

