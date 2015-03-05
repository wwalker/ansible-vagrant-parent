#!/bin/bash

set -e -o pipefail

vagrant up ctrl-01 --provider=libvirt
vagrant up exec-01 --provider=libvirt

vagrant ssh-config > ssh.config
