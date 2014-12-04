FROM ubuntu:trusty

RUN apt-get -q update

RUN apt-get -y install dnsmasq wget syslinux nginx

ENV pxe_ip 192.168.56.20
ENV pxe_net 192.168.56.0
ENV pxe_bcast 192.168.56.255
ENV pxe_mask 255.255.255.0
ENV pxe_min_ip 192.168.56.100
ENV pxe_max_ip 192.168.56.150
ENV coreos_version 494.0.0

ENV coreos_dir /data/tftpboot/$coreos_version

RUN mkdir -p /data /data/cache $coreos_dir

RUN	wget -P /data/cache "http://coreos.com/security/image-signing-key/CoreOS_Image_Signing_Key.pem" && \
	gpg --import /data/cache/CoreOS_Image_Signing_Key.pem

RUN wget -P $coreos_dir "http://storage.core-os.net/coreos/amd64-usr/${coreos_version}/coreos_production_pxe_image.cpio.gz.sig" && \
	wget -P $coreos_dir "http://storage.core-os.net/coreos/amd64-usr/${coreos_version}/coreos_production_pxe_image.cpio.gz"

RUN wget -P $coreos_dir "http://storage.core-os.net/coreos/amd64-usr/${coreos_version}/coreos_production_pxe.vmlinuz.sig" && \
	wget -P $coreos_dir "http://storage.core-os.net/coreos/amd64-usr/${coreos_version}/coreos_production_pxe.vmlinuz"

WORKDIR $coreos_dir
RUN gpg --verify coreos_production_pxe_image.cpio.gz.sig
RUN gpg --verify coreos_production_pxe.vmlinuz.sig
WORKDIR /

# (OUT OF BAND COPY pubkey) to ./sshkey.pub
COPY sshkey.pub /root/

# populate PXE stuff
RUN	mkdir -p /data/tftpboot/pxelinux.cfg && \
	cp /usr/lib/syslinux/pxelinux.0 /data/tftpboot

#	ssh_key=$(cat /root/sshkey.pub) echo "got key" && \

##
## file server and cloud-config
##
COPY makefiles.sh /usr/local/bin/
RUN /usr/local/bin/makefiles.sh

##
## add OEM cloud-config to image
##
RUN mkdir -p /data/usr/share/oem && \
	cp /data/ipxe/cloud-config-1.yml /data/usr/share/oem/cloud-config.yml

WORKDIR $coreos_dir
RUN gunzip -c coreos_production_pxe_image.cpio.gz > coreos_production_pxe_image.oem.cpio
WORKDIR /data
RUN find usr | cpio -o -A -H newc -O "${coreos_dir}/coreos_production_pxe_image.oem.cpio"
WORKDIR $coreos_dir
RUN gzip coreos_production_pxe_image.oem.cpio
WORKDIR /

RUN apt-get install -y strace vim nmap

# 53=dns
# 67,68=dhcp
CMD ["dnsmasq"]

# maybe use --listen-address=1.2.3.4 instead of --interface
#CMD \
#	dnsmasq --interface=vboxnet0 \
#	 		--except-interface=lo \
#			--dhcp-range=$pxe_min_ip,$pxe_max_ip,$pxe_mask,$pxe_bcast,1h \
#			--dhcp-boot=pxelinux.0 \
#			--pxe-service=x86PC,"Install Linux",pxelinux \
#	    	--enable-tftp \
#			--domain=demo.nexusvector.net \
#			--tftp-root=/data/tftpboot/ \
#			--no-daemon
