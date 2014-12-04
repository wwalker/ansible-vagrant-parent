ISO+ConfigDrive booting CoreOS without Vagrant
-----------------------------------------

This variant uses:

* configdrive pattern to initialize CoreOS on bare metal (in a VM)
* fileserve go program (in a docker container) for statics
** ./start.sh must be run to seed ./data
** must be externally started on top of the ./data directory

It requires some hand-holding in Virtualbox to configure all of the
relevant networks and stuff before starting on your journey.


Install routines (out of date)
------------------------------

1. assign names to the machines like imo where the name indicates
   placement:  core-r1-u2 or core-r1-u2-i10-0-10-5 ?

2. externally configure DHCP to

   * assign fixed ip addresses to machines

   * maybe also hand out hostnames directly to systemd's hostname thing

3. boot from ISO and no config drive

4. Drag down local-coreos-install & cloud-config sufficient to:

   * add control ssh-keys to core user

   * disable reboot policy

   * force disable etcd?

   * give the machine a hostname (unless DHCP did this)

   * add additional CA certificates to the trusted store for docker
   
5. Install to /dev/sda

6. Reboot without ISO

7. Add to ansible, push remaining cloud config stuff.
