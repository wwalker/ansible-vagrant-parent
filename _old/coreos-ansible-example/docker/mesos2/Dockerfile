FROM centos:centos6

#RUN wget http://downloads.mesosphere.io/master/centos/6/mesos-0.20.1-1.0.centos64.x86_64.rpm -O /tmp/mesos-0.20.1-1.0.centos64.x86_64.rpm
# sha256 should be 1ae248728f4cbce1ff670feb0a1e4a8e4a9f5ee293161088b6d5ea1805e8fa88
#RUN rpm -Uvh http://repos.mesosphere.io/el/6/noarch/RPMS/mesosphere-el-repo-6-2.noarch.rpm

COPY mesos-0.20.1-1.0.centos64.x86_64.rpm /tmp/

RUN rpm -Uvh /tmp/mesos-0.20.1-1.0.centos64.x86_64.rpm && \	
	rm -f /tmp/mesos-0.20.1-1.0.centos64.x86_64.rpm && \
	yum install -y wget curl unzip

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
