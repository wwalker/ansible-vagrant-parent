FROM ubuntu:trusty

# make 'sh' point to 'dash'
RUN echo "dash dash/sh boolean false" | debconf-set-selections && \
	DEBIAN_FRONTEND=noninteractive dpkg-reconfigure dash

# haproxy?
# vim nmap wget curl unzip

# update
# basic stuff
# java ppa
# java
# mesosphere ppa
# 
RUN apt-get update -qq && \
	apt-get install -y software-properties-common && \
	apt-get install -y python-software-properties && \
	apt-get install -y wget curl unzip && \
	echo oracle-java7-installer shared/accepted-oracle-license-v1-1 select true | debconf-set-selections && \
	apt-add-repository ppa:webupd8team/java && \
	apt-get update -qq && \
	apt-get install -y oracle-java7-installer oracle-java7-set-default && \
	apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv 81026D0004C44CF7EF55ADF8DF7D54CBE56151BF && \
	apt-add-repository 'deb http://repos.mesosphere.io/ubuntu trusty main' && \
	apt-get install -y zookeeper zookeeperd zookeeper-bin

COPY log4j.properties /etc/zookeeper/conf/
# TODO manufacture this from env vars in boot.sh
COPY zoo.cfg /etc/zookeeper/conf/

COPY boot.sh /bin/boot.sh

ENV JAVA_HOME "/usr/lib/jvm/java-7-oracle/"

	
EXPOSE 2181 2888 3888

VOLUME ["/data"]

#CMD ["/usr/share/zookeeper/bin/zkServer.sh", "start-foreground"]

CMD ["/bin/boot.sh"]
