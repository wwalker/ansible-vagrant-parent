#!/bin/bash

# https://raw.githubusercontent.com/coreos/init/master/bin/coreos-install

# wget http://172.12.8.10:8080/cloud-config-2.yml
# wget http://172.12.8.10:8080/local-coreos-install
# chmod +x local-coreos-install
# sudo ./local-coreos-install -d /dev/sda -V current -C stable -c cloud-config-2.yml -u http://172.12.8.10:8080

set -e -o pipefail
#set -x

CHANNEL_ID=stable
VERSION_ID=current

public_mac="08:00:27:fb:27:5a"
public_ip="192.168.0.30"
public_mask="24"
public_dns="192.168.0.1"
public_gw="192.168.0.1"

private_mac="08:00:27:81:b0:ea"
private_ip="172.12.8.50"
private_mask="24"

#file_urlbase="http://192.168.0.106:8080"
file_urlbase="http://172.12.8.10:8080"

discovery_url="https://discovery.etcd.io/51105ce8a2367812c0dcc150c0c63e36"

# Image signing key: buildbot@coreos.com
readonly GPG_LONG_ID="50E0885593D2DCB4"

die() {
  echo "ERROR: ${1}"
  exit 1
}

wgetsafe() {
  url="${1}"
  file="${2}"
  [[ -n "${url}" ]] || die "missing url"
  [[ -n "${file}" ]] || die "missing file"
  wget -nv "${url}" -O "${file}.tmp"
  sync
  mv "${file}.tmp" "${file}"
}

gpgverify() {
	file="${1}"
	[[ -n "${file}" ]] || die "missing file"
	gpg --batch --trusted-key "${GPG_LONG_ID}" --verify "${file}.sig"
}

download_and_verify() {
  url="${1}"
  file="${2}"
  [[ -n "${url}" ]] || die "missing url"
  [[ -n "${file}" ]] || die "missing file"

  echo "download_and_verify(\"${url}\", \"${file}\")"

  [[ -e "${file}.sig" ]] || {
	  wgetsafe "${url}.sig" "${file}.sig"
  }
  gpgverify "${file}" || {
	  echo "failed"
	  wgetsafe "${url}" "${file}"
	  gpgverify "${file}"
  }
}

mkdir -p ./data ./data/cache

# get signing key
[[ -e ./data/cache/CoreOS_Image_Signing_Key.pem ]] || {
    wget -P ./data/cache "http://coreos.com/security/image-signing-key/CoreOS_Image_Signing_Key.pem"
}
gpg --import ./data/cache/CoreOS_Image_Signing_Key.pem

readonly base_dir="./data/amd64-usr/${CHANNEL_ID}/${VERSION_ID}"
readonly base_url="http://${CHANNEL_ID}.release.core-os.net/amd64-usr/${VERSION_ID}"
readonly iso_name=coreos_production_iso_image.iso
readonly img_name=coreos_production_image.bin.bz2

mkdir -p "${base_dir}"
pushd "${base_dir}" >/dev/null
for filename in "${img_name}" "${iso_name}"; do
	download_and_verify "${base_url}/${filename}" "${filename}"
done
popd >/dev/null

cp ~/.ssh/id_rsa.pub ./data/sshkey.pub
cp ./local-coreos-install ./data/

ssh_key=$(cat ~/.ssh/id_rsa.pub)

# the "1" means stage-1
cat > ./data/cloud-config-1.yml <<EOF
#cloud-config

hostname: core-01

ssh_authorized_keys:
  - ${ssh_key}

write_files:
  - path: /root/custom-coreos-install
    permissions: 0755
    owner: root
    content: |
      #!/bin/bash
      /usr/bin/coreos-install -d /dev/sda -V ${VERSION_ID} -C ${coreos_install_channel} -c /media/configdrive/openstack/latest/user_data.stage2
  - path: /root/custom2-coreos-install
    permissions: 0755
    owner: root
    content: |
      #!/bin/bash
      wget ${file_urlbase}/local-coreos-install /root/local-coreos-install
      chmod 755 /root/local-coreos-install
      /usr/bin/coreos-install -d /dev/sda -V ${VERSION_ID} -C ${coreos_install_channel} -c /media/configdrive/openstack/latest/user_data.stage2

coreos:
  units:
#    - name: force_install.service
#      command: start
#      content: |
#        [Unit]
#        After=network-online.target
#        Description=Force Install CoreOS to disk
#        Requires=network-online.target
#        
#        [Service]
#        ExecStart=/usr/bin/coreos-install -d /dev/sda -V ${VERSION_ID} -C ${coreos_install_channel} -c /media/configdrive/openstack/latest/user_data.stage2
#        ExecStart=/usr/sbin/reboot
#        RemainAfterExit=yes
#        Type=oneshot
  update:
    group: ${coreos_install_channel}
    reboot-strategy: off
EOF

# http://www.freedesktop.org/software/systemd/man/systemd.unit.html
#
#coreos:
#  units:
#    - name: foo.service
#      content: |
#        [Unit] 
#        ConditionHost=core-01

etcd_servers="${private_ip}:7001"

# https://github.com/coreos/coreos-cloudinit/blob/master/config/etcd.go

cat > ./data/cloud-config-2.yml <<EOF
#cloud-config

hostname: core-01
ssh_authorized_keys:
  - ${ssh_key}
coreos:
  etcd:
#    discovery: ${discovery_url}
    addr: ${public_ip}:4001
    peer-addr: ${private_ip}:7001
    peer-heartbeat-interval: 250
    peer-election-timeout: 1000
    peers: ${etcd_servers}
  fleet:
    etcd-servers: ${etcd_servers}
  units:
    - name: 00-publicstatic.network
      runtime: false
      content: |
        [Match]
        Name=enp0s3
        #MACAddress=${public_mac}
        
        [Network]
        DHCP=none
        Address=${public_ip}/${public_mask}
        DNS=${public_dns}
        Gateway=${public_gw}
    - name: 10-privatestatic.network
      runtime: false
      content: |
        [Match]
        Name=enp0s8
        #MACAddress=${private_mac}
        
        [Network]
        DHCP=none
        Address=${private_ip}/${private_mask}
        #Gateway=172.12.8.1
        #DNS=8.8.8.8
        #DNS=8.8.4.4
    - name: etcd.service
      command: start
    - name: fleet.service
      enable: false
      #command: start
    - name: locksmithd.service
      enable: false
      #command: start
    - name: docker.socket
      command: start
  update:
    group: ${coreos_install_channel}
    reboot-strategy: best-effort
#  oem:
#    id: coreos
#    name: CoreOS Custom
#    version-id: ${coreos_version}
#    home-url: https://coreos.comxxxxxx
EOF

#    - name: static.network
#      command: start
#      content: |
#        [Match]
#        Name=enp0s8
#
#        [Network]
#        Address=172.12.8.50/24
#        DNS=8.8.8.8
#        DNS=8.8.4.4
#        Gateway=172.12.8.1


##
## make config drive
## https://github.com/coreos/coreos-cloudinit/blob/master/Documentation/config-drive.md
##
mkdir -p ./data/cache/new-drive/openstack/latest
cp ./data/cloud-config-1.yml ./data/cache/new-drive/openstack/latest/user_data
cp ./data/cloud-config-2.yml ./data/cache/new-drive/openstack/latest/user_data.stage2
mkisofs -R -V config-2 -o ./data/configdrive.iso ./data/cache/new-drive
sync

