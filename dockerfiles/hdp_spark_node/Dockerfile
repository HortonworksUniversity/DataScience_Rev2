#
#
#
FROM hwx/hdp_node
MAINTAINER Rich Raposa, rich@hortonworks.com

#Install Fortran package needed by Spark MLLib
RUN yum -y install gcc-gfortran --enablerepo=updates 

#Install Spark and Spark Python module
RUN rpm -Uvh http://public-repo-1.hortonworks.com/spark/centos6/rpms/spark-core-0.9.1.2.1.1.0-22.el6.noarch.rpm
RUN rpm -Uvh http://public-repo-1.hortonworks.com/spark/centos6/rpms/spark-python-0.9.1.2.1.1.0-22.el6.noarch.rpm

# Set environment variables needed to run Spark on YARN 
RUN echo "export YARN_CONF_DIR=/etc/hadoop/conf" >> /etc/bashrc
RUN echo "export SPARK_YARN_MODE=true" >> /etc/bashrc
RUN echo "export SPARK_JAR=/usr/lib/spark/lib/spark-assembly_2.10-0.9.1.2.1.1.0-22-hadoop2.4.0.2.1.1.0-385.jar" >> /etc/bashrc
RUN echo "export SPARK_YARN_APP_JAR=/usr/lib/spark/examples/lib/spark-examples_2.10-0.9.1.2.1.1.0-22.jar" >> /etc/bashrc
RUN echo "export SPARK_WORKER_MEMORY=512m" >> /etc/bashrc
RUN echo "export SPARK_MASTER_MEMORY=512m" >> /etc/bashrc
RUN echo "export MASTER=yarn-client" >> /etc/bashrc

# Fix bug in spark-shell script
RUN sed -i "/\/usr\/lib\/spark\/spark-shell/c\\/usr\/lib\/spark\/bin\/spark-shell" /usr/bin/spark-shell

# Hack: link Python 2.7 to /usr/bin so that Spark will work in YARN. Need to figure out how to properly set YARN env variables to avoid having to make this change
RUN mv /usr/bin/python /usr/bin/python.old
RUN ln -s /anaconda/bin/python /usr/bin/python

#Install Anaconda Python package. Spark MLLib requires Python 2.7, which doesn't come standard in CentOS
RUN wget http://09c8d0b2229f813c1b93-c95ac804525aac4b6dba79b00b39d1d3.r79.cf1.rackcdn.com/Anaconda-1.9.2-Linux-x86_64.sh
RUN bash Anaconda-1.9.2-Linux-x86_64.sh -b
RUN rm -f Anaconda-1.9.2-Linux-x86_64.sh
RUN echo "export PATH=\"/anaconda/bin:$PATH\"" >> /etc/bashrc
