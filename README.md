# grubdefmod
Updates /etc/default/grub

The 'grubby' tool does a good job of maintaing the grub2 configuration but for some reason it fails to update
the /etc/default/grub file on RHEL7 servers.

I created this bash script to safely update the /etc/default/grub file and also update the grub2 configuration
afterwards.
