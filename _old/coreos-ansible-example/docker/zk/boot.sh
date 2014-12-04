#!/bin/bash

set -e

echo 1 > /data/myid

chown -R zookeeper:zookeeper /data

# limit nofile 8192 8192
#ulimit -S -n 8192
#ulimit -H -n 8192

export JAVA_HOME=/usr/lib/jvm/java-7-oracle/

exec su -m -s /bin/bash -c '/usr/share/zookeeper/bin/zkServer.sh start-foreground' zookeeper
#exec /usr/share/zookeeper/bin/zkServer.sh start-foreground
