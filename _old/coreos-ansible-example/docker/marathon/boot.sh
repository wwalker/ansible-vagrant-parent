#!/bin/bash

set -e
#set -x

function die {
	echo "$1"
	exit 2
}

[[ -n "${ZOOKEEPER_ENDPOINTS}" ]] || die "ZOOKEEPER_ENDPOINTS not set"
[[ -n "${MARATHON_IP}" ]] || die "MARATHON_IP not set"

export MARATHON_hostname="${MARATHON_IP}"
#export MARATHON_work_dir=/data
#export MARATHON_log_dir=/mesoslog

export MARATHON_master="zk://${ZOOKEEPER_ENDPOINTS}/mesos"
export MARATHON_zk="zk://${ZOOKEEPER_ENDPOINTS}/marathon"
# 5min, matches what we use for the slaves
export MARATHON_task_launch_timeout=3001000

exec /usr/local/bin/marathon
