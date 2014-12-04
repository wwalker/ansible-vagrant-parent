#!/bin/bash

set -e -o pipefail

mkdir -p /data/ipxe

readonly ssh_key=$(cat /root/sshkey.pub)

cat > /data/ipxe/cloud-config-1.yml <<EOF
#cloud-config

#hostname: coreos-1
ssh_authorized_keys:
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

cp -a /etc/dnsmasq.conf /etc/dnsmasq.conf.dist

cat > /etc/dnsmasq.conf <<EOF
listen-address=192.168.56.1
#interface=vboxnet0
#except-interface=lo
#except-interface=lxcbr0
#except-interface=docker0
#except-interface=wlan0
#except-interface=vboxnet1
log-dhcp
dhcp-authoritative
dhcp-range=$pxe_min_ip,$pxe_max_ip,$pxe_mask,$pxe_bcast,1h
dhcp-boot=pxelinux.0
dhcp-host=08:00:27:84:E8:A5,192.168.56.14,test1
pxe-service=x86PC,"Install Linux",pxelinux
enable-tftp
domain=demo.nexusvector.net
tftp-root=/data/tftpboot/
no-daemon
EOF

##
## setup DHCP
##
cat > /etc/dhcp/dhcpd.conf <<EOF
ddns-update-style none;

authoritative;

log-facility local7;

allow booting;
allow bootp;

subnet 10.0.0.0 netmask 255.255.0.0 {
}

subnet ${pxe_net} netmask ${pxe_mask} {
  range ${pxe_min_ip} ${pxe_max_ip};
  option broadcast-address ${pxe_bcast};
  option routers ${pxe_ip};
  option domain-name "demo.nexusvector.net";
  option domain-name-servers 8.8.8.8, 8.8.4.4;
  default-lease-time 600;
  max-lease-time 7200;

  filename "pxelinux.0";
}

host pxe_test1 {
  hardware ethernet 08:00:27:84:E8:A5;
  fixed-address 192.168.56.14;
  server-name "test1";
}
EOF
