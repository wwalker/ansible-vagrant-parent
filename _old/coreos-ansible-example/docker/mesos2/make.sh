#!/bin/sh

set -e

sudo docker build -t naelyn/mesos-centos .
sudo docker tag naelyn/mesos-centos crusher:5050/naelyn/mesos-centos

sudo docker push naelyn/mesos-centos
sudo docker push crusher:5050/naelyn/mesos-centos
