## setup

see installation.txt

## detail
### acri-startup.rb
1. Write one of the default FPGA bitstreams (../vs_default)
2. Set up config files (sshd_config and xrdp.ini),
   in order to let only the reserved user use the VM

The limitaton of user is enabled only if
- the installation folder of Vivado is present,
- the last two letters of the hostname are in 01-15 and
- an Arty board is connected.

### acri-startup.service
A service that runs `acri-startup.rb` and copies the config files on `/etc`.
>     $ sudo cp acri-startup.service /lib/systemd/system/
>     $ sudo systemctl enable acri-startup.service