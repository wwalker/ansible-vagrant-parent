#!/bin/bash

set -e
#set -x

function die {
	echo "$1"
	exit 2
}

[[ -n "${1}" ]] || die "require one arg to be <master|slave>"

readonly request="${1}"

[[ -n "${ZOOKEEPER_ENDPOINTS}" ]] || die "ZOOKEEPER_ENDPOINTS not set"
[[ -n "${MESOS_IP}" ]] || die "MESOS_IP not set"
readonly quorum="${MESOS_QUORUM:-1}"

mkdir -p /data

# no mesos user

# limit nofile 8192 8192
ulimit -S -n 8192
ulimit -H -n 8192

export MESOS_HOSTNAME="${MESOS_IP}"
export MESOS_work_dir=/data
export MESOS_log_dir=/mesoslog

case "${request}" in
	master)
		#			--zk="zk://${ZOOKEEPER_ENDPOINTS}/mesos" \
		#			--ip="${MESOS_IP}" \
		#			--hostname="${MESOS_IP}" \
		#			--quorum="${quorum}" \
		echo "Starting as mesos-master..."

		export MESOS_ZK="zk://${ZOOKEEPER_ENDPOINTS}/mesos"
		exec /usr/local/sbin/mesos-master
		;;
	slave)
		echo "Starting as mesos-slave..."

		export MESOS_MASTER="zk://${ZOOKEEPER_ENDPOINTS}/mesos"
		exec /usr/local/sbin/mesos-slave \
			--containerizers="docker,mesos" \
			--executor_registration_timeout="5mins"
		;;
	*)
		die "bad mode"
		;;
esac

