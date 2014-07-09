#
#
#
FROM hwxu/hdp_anaconda_node
MAINTAINER Rich Raposa, rich@hortonworks.com

# Copy Avro MR lib to Hadoop classpath
RUN cp /usr/lib/pig/lib/avro-mapred-1.7.4.jar /usr/lib/hadoop/lib/avro-mapred-1.7.4.jar

ADD start-scripts/ /root/start-scripts
ADD scripts/  /root/scripts
ADD ipython/ /root/.ipython/profile_nbserver
RUN mkdir -p .config/matplotlib
RUN echo "backend: Agg" > .config/matplotlib/matplotlibrc
 
RUN /anaconda/bin/pip install avro 
 
EXPOSE 22 8888 9999


ENTRYPOINT ["/root/scripts/startup.sh"]
