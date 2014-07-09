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

#Install Spark 
RUN wget https://s3-us-west-1.amazonaws.com/vm-us-west/spark-1.0.0-bin-2.4.0.2.1.3.0-563.tgz -O /tmp/spark.tgz
RUN tar -C /usr/lib -zxvf /tmp/spark.tgz
RUN ln -s /usr/lib/spark-1.0.0-bin-2.4.0.2.1.3.0-563 /usr/lib/spark
RUN rm -f /tmp/spark.tgz

# Set environment variables needed to run Spark on YARN 
RUN echo "export YARN_CONF_DIR=/etc/hadoop/conf" >> /etc/bashrc
RUN echo "export SPARK_JAR=/usr/lib/spark/lib/spark-assembly-1.0.0-hadoop2.4.0.2.1.3.0-563.jar" >> /etc/bashrc
RUN echo "export SPARK_WORKER_MEMORY=512m" >> /etc/bashrc
RUN echo "export SPARK_MASTER_MEMORY=512m" >> /etc/bashrc
RUN echo "export MASTER=yarn-client" >> /etc/bashrc
RUN echo "export SPARK_HOME=/usr/lib/spark" >> /etc/bashrc
RUN echo "export PYTHONPATH=\$SPARK_HOME/python/:\$PYTHONPATH" >> /etc/bashrc
RUN echo "export PYTHONPATH=\$SPARK_HOME/python/lib/py4j-0.8.1-src.zip:\$PYTHONPATH" >> /etc/bashrc
RUN echo "export SPARK_YARN_USER_ENV=\"PYTHONPATH=/usr/lib/spark/python/lib/py4j-0.8.1-src.zip:/usr/lib/spark/python/:\$PYTHONPATH\"" >> /etc/bashrc

# Hack: link Python 2.7 to /usr/bin so that Spark will work in YARN. Need to figure out how to properly set YARN env variables to avoid having to make this change
RUN mv /usr/bin/python /usr/bin/python.old
RUN ln -s /anaconda/bin/python /usr/bin/python
