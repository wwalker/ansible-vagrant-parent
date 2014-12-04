#!/bin/bash

# vagrant: ubuntu/trusty64

# TODO: steal from https://github.com/radial/wheel-coreos-pxe/blob/master/spoke/entrypoint.sh

# nmap -p 53-70 -sU
# 53=dns, 67/68=dhcp, 69=tftp

set -eo pipefail

# https://help.ubuntu.com/community/DisklessUbuntuHowto

readonly pxe_ip=192.168.56.20
readonly pxe_net=192.168.56.0
readonly pxe_bcast=192.168.56.255
readonly pxe_mask=255.255.255.0
readonly pxe_min_ip=192.168.56.100
readonly pxe_max_ip=192.168.56.150
readonly coreos_version="494.0.0"

readonly coreos_dir="/data/tftpboot/${coreos_version}"

##
## functions
##

die() {
  echo "ERROR: ${1}"
  exit 1
}

wgetsafe() {
  url="${1}"
  file="${2}"
  [[ -n "${url}" ]] || die "missing url"
  [[ -n "${file}" ]] || die "missing file"
  wget "${url}" -O "${file}.tmp"
  sync
  mv "${file}.tmp" "${file}"
}


# (OUT OF BAND COPY pubkey) to /data/sshkey.pub
##
## read pubkey into ram
##
readonly ssh_key=$(cat /data/sshkey.pub)

##
## install stuff
##
apt-get install -y dnsmasq syslinux nginx
# dhcp3-server tftpd-hpa  nfs-kernel-server initramfs-tools

cp -a /etc/dnsmasq.conf /etc/dnsmasq.conf.dist
rm -f /etc/resolv.conf
echo "nameserver 10.0.2.2" > /etc/resolv.conf
chattr +i /etc/resolv.conf

mkdir -p /data /data/cache

##
## populate PXE stuff
##
mkdir -p /data/tftpboot/pxelinux.cfg
cp /usr/lib/syslinux/pxelinux.0 /data/tftpboot

# get signing key
[[ -e /data/cache/CoreOS_Image_Signing_Key.pem ]] || {
    wget -P /data/cache "http://coreos.com/security/image-signing-key/CoreOS_Image_Signing_Key.pem"
}
gpg --import /data/cache/CoreOS_Image_Signing_Key.pem

mkdir -p "${coreos_dir}"
pushd "${coreos_dir}" >/dev/null

# fetch sigs
for file in \
  coreos_production_pxe_image.cpio.gz.sig \
  coreos_production_pxe.vmlinuz.sig; do
  url="http://storage.core-os.net/coreos/amd64-usr/${coreos_version}/${file}"
  wgetsafe "${url}" "${file}"
#  wget "${url}" -O "${file}.tmp"
#  sync
#  mv "${file}.tmp" "${file}"
done

for file in \
  coreos_production_pxe_image.cpio.gz \
  coreos_production_pxe.vmlinuz; do
  gpg --verify "${file}.sig" || {
    url="http://storage.core-os.net/coreos/amd64-usr/${coreos_version}/${file}"
    wgetsafe "${url}" "${file}"
    gpg --verify "${file}.sig"
  }
done
popd >/dev/null

##
## file server and cloud-config
##
mkdir -p /data/ipxe
cat > /data/ipxe/cloud-config-1.yml <<EOF
#cloud-config

#hostname: coreos-1
ssh_authorized_keys:
  - ${ssh_key}
users:
  - name: naelyn
    groups:
      - sudo
      - docker
    ssh-authorized-keys:
      - ${ssh_key}
coreos:
  etcd:
    addr: \$private_ipv4:4001
    peer-addr: \$private_ipv4:7001
    peer-heartbeat-interval: 250
    peer-election-timeout: 1000
  units:
    - name: etcd.service
      command: start
    - name: fleet.service
      command: start
    - name: docker.socket
      command: start
  update:
    group: alpha
    reboot-strategy: best-effort
#  oem:
#    id: coreos
#    name: CoreOS Custom
#    version-id: ${coreos_version}
#    home-url: https://coreos.comxxxxxx
EOF

##
## add OEM cloud-config to image
##
mkdir -p /data/usr/share/oem
cp /data/ipxe/cloud-config-1.yml /data/usr/share/oem/cloud-config.yml

pushd "${coreos_dir}" >/dev/null
gunzip -c coreos_production_pxe_image.cpio.gz > coreos_production_pxe_image.oem.cpio
pushd "/data" >/dev/null && \
  find usr | cpio -o -A -H newc -O "${coreos_dir}/coreos_production_pxe_image.oem.cpio" && \
  popd >/dev/null
rm -f coreos_production_pxe_image.oem.cpio.gz
gzip coreos_production_pxe_image.oem.cpio
popd > /dev/null

##
## setup dnsmasq (dhcpd + tftp)
##
cat > /etc/dnsmasq.conf <<EOF
listen-address=$pxe_ip
#log-dhcp
no-resolv
server=8.8.8.8
server=8.8.4.4
dhcp-authoritative
dhcp-range=$pxe_min_ip,$pxe_max_ip,$pxe_mask,$pxe_bcast,1h
dhcp-boot=pxelinux.0
dhcp-host=08:00:27:84:E8:A5,192.168.56.14,test1
pxe-service=x86PC,"Install Linux",pxelinux
enable-tftp
domain=demo.nexusvector.net
tftp-root=/data/tftpboot/
EOF

service dnsmasq restart

cat > /data/tftpboot/pxelinux.cfg/default <<EOF
default coreos
prompt 1
timeout 15

display boot.msg

label coreos
  menu default
  kernel ${coreos_version}/coreos_production_pxe.vmlinuz
  append rootfstype=btrfs initrd=${coreos_version}/coreos_production_pxe_image.oem.cpio.gz coreos.autologin
EOF
#  cloud-config-url=http://192.168.56.20/cloud-config-1.yml
# console=tty0 console=ttyS0  coreos.autologin=tty0 coreos.autologin=ttyS0

# ip=dhcp
# cloud-config-url=http://example.com/pxe-cloud-config.yml

chmod -R 777 /data/tftpboot

#service tftpd-hpa restart

#cp -a /vagrant/fileserve /usr/bin && chmod +x /usr/bin/fileserve
#cat > /etc/init/fileserve.conf <<EOF
#description "file server"
#start on started networking
#stop on shutdown
#console log
#respawn
#env GOMAXPROCS=2
#export GOMAXPROCS
#exec /usr/bin/fileserve -d=/vagrant/ipxe -http=:80
#EOF
#service fileserve start


cat > /etc/nginx/sites-available/default <<EOF
server {
  listen 80 default_server;
  #listen [::]:80 default_server ipv6only=on;

  #default_type application/octet-stream;
  #sendfile     on;
  #tcp_nopush   on;

  root /data/ipxe;
  #index index.html index.htm;

  server_name _;
  server_name_in_redirect off;

 # location / {
    #autoindex on;
 # }
}
EOF

service nginx restart


# comes up with hostname
# sudo coreos-install -d /dev/sda -c /usr/share/oem/cloud-config.yml


exit 0

##
## setup DHCP
##
#cat > /etc/dhcp/dhcpd.conf <<EOF
#ddns-update-style none;
#
#authoritative;
#
#log-facility local7;
#
#allow booting;
#allow bootp;
#
#subnet 10.0.0.0 netmask 255.255.0.0 {
#}
#
#subnet ${pxe_net} netmask ${pxe_mask} {
#  range ${pxe_min_ip} ${pxe_max_ip};
#  option broadcast-address ${pxe_bcast};
#  option routers ${pxe_ip};
#  option domain-name "demo.nexusvector.net";
#  option domain-name-servers 8.8.8.8, 8.8.4.4;
#  default-lease-time 600;
#  max-lease-time 7200;
#
#  filename "pxelinux.0";
#}
#
#host pxe_test1 {
#  hardware ethernet 08:00:27:84:E8:A5;
#  fixed-address 192.168.56.14;
#  server-name "test1";
#}
#EOF
#
#
#/etc/init.d/isc-dhcp-server restart



#cat > /etc/default/tftpd-hpa <<EOF
#RUN_DAEMON="yes"
#TFTP_USERNAME=vagrant
#TFTP_ADDRESS="0.0.0.0:69"
#TFTP_DIRECTORY="/data/tftpboot"
#TFTP_OPTIONS="-v -4 -s"
#EOF



#dpkg-reconfigure tftpd-hpa

# /var/lib/tftpboot

# port 69

####### DEFAULTS ##########
# /etc/default/tftpd-hpa
#TFTP_USERNAME="tftp"
#TFTP_DIRECTORY="/var/lib/tftpboot"
#TFTP_ADDRESS="[::]:69"
#TFTP_OPTIONS="--secure"

pushd /var/lib/tftpboot
mkdir {openbsd,freebsd,netbsd}
mkdir -p linux/{debian,ubuntu,rhel,centos,fedora,suse}
mkdir -p firmwares/{linksys,cisco,soekris,pata,sata,ipmi,nic}
ls -l
ls -l linux/
ls -l firmwares/
popd

sudo apt-get install dhcp3-server tftpd-hpa syslinux nfs-kernel-server initramfs-tools
