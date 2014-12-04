#!/bin/sh

set -e

sudo docker build -t naelyn/mesos .
sudo docker tag naelyn/mesos crusher:5050/naelyn/mesos

sudo docker push naelyn/mesos
sudo docker push crusher:5050/naelyn/mesos
