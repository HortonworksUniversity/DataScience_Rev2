#
#
#
FROM hwxu/hdp_node
MAINTAINER Rich Raposa, rich@hortonworks.com



#Install the Anaconda distribution of Python, which contains IPython and all analytic/scientific libs
RUN wget http://09c8d0b2229f813c1b93-c95ac804525aac4b6dba79b00b39d1d3.r79.cf1.rackcdn.com/Anaconda-1.9.2-Linux-x86_64.sh
RUN bash Anaconda-1.9.2-Linux-x86_64.sh -b
RUN rm -f Anaconda-1.9.2-Linux-x86_64.sh
RUN echo "export PATH=\"/anaconda/bin:$PATH\"" >> /etc/bashrc
RUN echo "export PATH=\"/anaconda/bin:$PATH\"" >> /etc/profile
RUN source /etc/bashrc
RUN /anaconda/bin/ipython profile create nbserver
RUN /anaconda/bin/conda update ipython
RUN /anaconda/bin/conda update conda

