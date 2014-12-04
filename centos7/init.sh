#!/bin/bash

set -e -o pipefail

# yum install yum-utils
# yumdownloader THING

die() {
  echo "ERROR: ${1}"
  exit 1
}

wgetsafe() {
  url="${1}"
  file="${2}"
  [[ -n "${url}" ]] || die "missing url"
  [[ -n "${file}" ]] || die "missing file"
  echo "fetching: ${url}"
  wget -nv "${url}" -O "${file}.tmp"
  sync
  mv "${file}.tmp" "${file}"
}

mkdir -p ./data

cd ./data

########################################################
## fetch things that basically don't change only once ##

[[ -e RPM-GPG-KEY-cloudera ]] || {
	wgetsafe "http://archive.cloudera.com/cdh4/redhat/6/x86_64/cdh/RPM-GPG-KEY-cloudera" "RPM-GPG-KEY-cloudera"
}

#centos6 cdh4 stuff


#centos6
[[ -e epel-release-6-8.noarch.rpm ]] || {
	wgetsafe "http://dl.fedoraproject.org/pub/epel/6/x86_64/epel-release-6-8.noarch.rpm" "epel-release-6-8.noarch.rpm"
}

# centos7
[[ -e epel-release-7-2.noarch.rpm ]] || {
	wgetsafe "http://dl.fedoraproject.org/pub/epel/7/x86_64/e/epel-release-7-2.noarch.rpm" "epel-release-7-2.noarch.rpm"
}

#centos6
[[ -e mesosphere-el-repo-6-2.noarch.rpm ]] || {
	wgetsafe "http://repos.mesosphere.io/el/6/noarch/RPMS/mesosphere-el-repo-6-2.noarch.rpm" "mesosphere-el-repo-6-2.noarch.rpm"
}

#centos7
#http://repos.mesosphere.io/el/7/noarch/RPMS/mesosphere-el-repo-7-1.noarch.rpm
# mesos                           x86_64                           0.20.1-1.0.centos701406

########################################################

[[ -e cloudera-cdh-4-0.x86_64.rpm ]] || {
	wgetsafe "http://archive.cloudera.com/cdh4/one-click-install/redhat/6/x86_64/cloudera-cdh-4-0.x86_64.rpm" "cloudera-cdh-4-0.x86_64.rpm"
}

#centos6
[[ -e mesos-0.21.0-1.0.centos65.x86_64.rpm ]] || {
	wgetsafe "http://downloads.mesosphere.io/master/centos/6/mesos-0.21.0-1.0.centos65.x86_64.rpm" "mesos-0.21.0-1.0.centos65.x86_64.rpm"
}

#centos7
#[[ -e mesos-0.20.1-1.0.centos701406.x86_64.rpm ]] || {
#	wgetsafe "http://downloads.mesosphere.io/master/centos/7/mesos-0.20.1-1.0.centos701406.x86_64.rpm" "mesos-0.20.1-1.0.#centos701406.x86_64.rpm"
#}

#centos6
[[ -e marathon-0.7.5-1.0.x86_64.rpm ]] || {
	wgetsafe "http://downloads.mesosphere.io/marathon/v0.7.5/marathon-0.7.5-1.0.x86_64.rpm" "marathon-0.7.5-1.0.x86_64.rpm"
}

## consul

[[ -e consul-0.4.1_linux_amd64.zip ]] || {
	wgetsafe "https://dl.bintray.com/mitchellh/consul/0.4.1_linux_amd64.zip" "consul-0.4.1_linux_amd64.zip"
}

[[ -e consul-0.4.1_web_ui.zip ]] || {
	wgetsafe "https://dl.bintray.com/mitchellh/consul/0.4.1_web_ui.zip" "consul-0.4.1_web_ui.zip"
}
