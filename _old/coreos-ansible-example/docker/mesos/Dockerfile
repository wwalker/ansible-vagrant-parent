FROM ubuntu:trusty

# make 'sh' point to 'dash'
RUN echo "dash dash/sh boolean false" | debconf-set-selections && \
	DEBIAN_FRONTEND=noninteractive dpkg-reconfigure dash

# haproxy?
# vim nmap wget curl unzip

# update
# basic stuff
# mesosphere ppa
# 
RUN apt-get update -qq && \
	apt-get install -y software-properties-common && \
	apt-get install -y python-software-properties && \
	apt-get install -y wget curl unzip && \
	apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv 81026D0004C44CF7EF55ADF8DF7D54CBE56151BF && \
	apt-add-repository 'deb http://repos.mesosphere.io/ubuntu trusty main' && \
	apt-get update -qq && \
	apt-get install -y mesos

# needed for the slave
RUN wget https://get.docker.com/builds/Linux/x86_64/docker-latest -O /usr/bin/docker && \
	chmod +x /usr/bin/docker

# configure mesos connection to zk
#RUN echo "zk://172.12.8.101:2181/mesos" > /etc/mesos/zk
#RUN echo "1" > /etc/mesos-master/quorum
#RUN echo "172.12.8.101" > /etc/mesos-master/ip && \
#	echo "172.12.8.101" > /etc/mesos-master/hostname

RUN rm -rf /etc/mesos /etc/mesos-slave /etc/mesos-master

RUN mkdir -p /mesoslog

# http master
EXPOSE 5050 

# http slave
EXPOSE 5051 

#CMD ["/usr/local/sbin/mesos-master", "--zk=\"zk://$ZOOKEEPER_ENDPOINTS/mesos" --ip=$COREOS_PUBLIC_IPV4 --quorum=1 --work_dir=/var/lib/mesos

COPY boot.sh /bin/boot.sh

VOLUME ["/data","/mesoslog"]

ENTRYPOINT ["/bin/boot.sh"]
