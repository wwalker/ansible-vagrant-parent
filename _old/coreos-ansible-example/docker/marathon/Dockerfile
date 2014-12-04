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
	apt-get install --no-install-recommends -y software-properties-common python-software-properties && \
	apt-get install --no-install-recommends -y wget curl unzip && \
	apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv 81026D0004C44CF7EF55ADF8DF7D54CBE56151BF && \
	apt-add-repository 'deb http://repos.mesosphere.io/ubuntu trusty main' && \
	apt-get update -qq && \
	apt-get install --no-install-recommends -y marathon

RUN locale-gen en_US.UTF-8

#RUN apt-get update && apt-get install -y default-jre wget
#RUN wget -O /tmp/marathon.tgz -c http://downloads.mesosphere.io/marathon/marathon-0.6.1/marathon-0.6.1.tgz
#RUN tar xzf /tmp/marathon.tgz -C /usr/local/
#RUN ln -s /usr/local/marathon-0.6.1 /usr/local/marathon

# TODO: log4j to stdout/stderr
COPY log4j.properties /

RUN cp -a /usr/local/bin/marathon /usr/local/bin/marathon.dist && \
	   sed -i '/Xmx512/a -Dlog4j.configuration=file:/log4j.properties' /usr/local/bin/marathon

COPY boot.sh /bin/boot.sh

EXPOSE 8080

VOLUME ["/data"]

CMD ["/bin/boot.sh"]
