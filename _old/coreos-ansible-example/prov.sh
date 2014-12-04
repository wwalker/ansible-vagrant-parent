#!/bin/bash

set -e

vagrant provision

vagrant ssh -c 'sudo coreos-cloudinit --from-file /var/lib/coreos-vagrant/vagrantfile-user-data'
