#
#
#
FROM hwx/hdp_python_node
MAINTAINER Rich Raposa, rich@hortonworks.com

# Make sure that Mahout is installed (should normally be done in a base HDP image)
RUN yum -y install mahout

# Install base Ruby packages for web front end used in Mahout labs
RUN yum -y install gcc gcc-c++ ruby ruby-devel rubygems 

# Install additional Ruby gems needed by web front end for Mahout labs
RUN gem install sinatra --no-ri --no-rdoc
RUN gem install fastercsv --no-ri --no-rdoc
RUN gem install json --no-ri --no-rdoc
