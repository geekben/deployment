installation
=====

###u disk
*  need to use ubuntu's “startup disk creator” to make a startup disk, other tool may encounter cdrom can't mount error
*  sometimes, need to insert the u disk before reboot to turn on USB boot in BIOS

###hard drive
* use easybcd add an entry to windows grub

configuration
=====

###keep it awake
* add the kernel options "acpi=off apm=off" to the GRUB_CMDLINE_LINUX_DEFAULT in /etc/default/grub, then reboot