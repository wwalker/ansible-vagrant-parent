#!/bin/sh

set -e

sudo docker build -t naelyn/marathon .
sudo docker tag naelyn/marathon crusher:5050/naelyn/marathon

sudo docker push naelyn/marathon
sudo docker push crusher:5050/naelyn/marathon
