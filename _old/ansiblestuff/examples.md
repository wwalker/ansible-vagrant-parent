In order to deploy a Docker container we need to POST a JSON task
description to http://<master>:8080/apps. Below is the Docker.json file.

{
  "container": {
    "type": "DOCKER",
    "docker": {
      "image": "libmesos/ubuntu"
    }

	"network": "BRIDGE",
      "portMappings": [
        { "containerPort": 8080, "hostPort": 0, "protocol": "tcp"},
        { "containerPort": 161, "hostPort": 0, "protocol": "udp"}
      ]

    "volumes": [
      {
        "containerPath": "/etc/a",
        "hostPath": "/var/data/a",
        "mode": "RO"
      },
      {
        "containerPath": "/etc/b",
        "hostPath": "/var/data/b",
        "mode": "RW"
      }
    ]
  },
  "id": "ubuntu",
  "instances": "1",
  "cpus": "0.5",
  "mem": "512",
  "uris": [],
  "cmd": "while sleep 10; do date -u +%T; done"
}

# For convenience, the mount point of the mesos sandbox is available in
# the environment as $MESOS_SANDBOX. The $HOME environment variable is
# set by default to the same value as $MESOS_SANDBOX.

The file can be posted with curl to Marathon using the command curl -X
POST -H "Content-Type: application/json" http://<master>:8080/v2/apps
-d@Docker.json, replacing <master> with the IP address of your
Mesosphere master.


