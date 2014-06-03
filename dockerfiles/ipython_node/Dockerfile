FROM ubuntu

MAINTAINER Rich Raposa, rich@hortonworks.com

RUN apt-get -y update
RUN apt-get -y install openssh-server openssh-client libagg-dev nano vim

#Install IPython and stats/scientific/nlp libraries
RUN apt-get -y install python-numpy python-scipy python-matplotlib ipython ipython-notebook python-pandas python-sympy python-nose build-essential python-dev python-setuptools libatlas-dev libatlas3-base python-pip 
RUN pip install -U scikit-learn
RUN pip install -U pyyaml
RUN pip install -U nltk
RUN pip install -U avro
RUN pip install -U ipython
RUN ipython profile create nbserver

#Optional: install the Anaconda distribution of Python, which contains IPython and all analytic/scientific libs
#RUN wget http://09c8d0b2229f813c1b93-c95ac804525aac4b6dba79b00b39d1d3.r79.cf1.rackcdn.com/Anaconda-1.9.2-Linux-x86_64.sh
#RUN bash Anaconda-1.9.2-Linux-x86_64.sh -b
#RUN rm -f Anaconda-1.9.2-Linux-x86_64.sh
#RUN echo "export PATH=\"/anaconda/bin:$PATH\"" >> /etc/bashrc
#RUN echo "export PATH=\"/anaconda/bin:$PATH\"" >> /etc/profile
#RUN /anaconda/bin/ipython profile create nbserver

ADD ipython/ /root/.ipython/profile_nbserver
RUN mkdir -p .config/matplotlib
RUN echo "backend: Agg" > .config/matplotlib/matplotlibrc

RUN echo "root:hadoop" | chpasswd

RUN ipython profile create nbserver
ADD ipython/ /root/.ipython/profile_nbserver
RUN mkdir -p .config/matplotlib 
RUN echo "backend: Agg" > .config/matplotlib/matplotlibrc

ADD scripts/ /root/scripts/

RUN mkdir /root/.ssh
ADD conf/id_rsa /root/.ssh/id_rsa
ADD conf/id_rsa.pub /root/.ssh/id_rsa.pub
ADD conf/sshd_config /etc/ssh/
ADD conf/nanorc /root/.nanorc

EXPOSE 22 8888

ENTRYPOINT ["/root/scripts/startup.sh"]

