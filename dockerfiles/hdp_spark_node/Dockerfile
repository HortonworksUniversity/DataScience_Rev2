#
#
#
FROM hwxu/hdp_python_node
MAINTAINER Rich Raposa, rich@hortonworks.com

#Install Fortran package needed by Spark MLLib
RUN yum -y install gcc-gfortran --enablerepo=updates 

# Install base Ruby packages for web front end used in Mahout labs
RUN yum -y install gcc gcc-c++ ruby ruby-devel rubygems

# Install additional Ruby gems needed by web front end for Mahout labs
RUN gem install sinatra --no-ri --no-rdoc
RUN gem install fastercsv --no-ri --no-rdoc
RUN gem install json --no-ri --no-rdoc

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
