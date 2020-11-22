
# Update VirtualBox

## Prepare

Before updating, stop all VMs running on the host.

```
crontab -e # edit crontab to disable 'start-vm.rb every 2min'.
/root/acri-olb/vm-host/stop-all-vms.sh
```

## Update VirtualBox

```
sudo yum install -y VirtualBox-6.1-6.1.16_140961_el7-1.x86_64.rpm
VboxManage extpack uninstall "Oracle VM VirtualBox Extension Pack"
VBoxManage extpack install Oracle_VM_VirtualBox_Extension_Pack-6.1.16.vbox-extpack
```

## Update GuestAddtions in each VM

```
crontab -e # edit crontab to enable 'start-vm.rb every 2min'.
```

After starting all VMs, attach GuestAdditions.iso to all VMs

```
for i in $(/root/acri-olb/vm-host/running-vms.rb); do VBoxManage storageattach $i --storagectl IDE --port 0 --device 0 --type dvddrive --medium /usr/share/virtualbox/VBoxGuestAdditions.iso; done
```

Login to each VM by SSH and execute the update script.

```
for i in $(seq 0 15); do sshpass -p [password] ssh -t [user]@172.16.[IP].$i "echo [password] | sudo -S /root/acri-olb/client/vbox-guest-update.sh"; done
```

After updating GuestAdditions

```
for i in $(seq 0 15); do sshpass -p [password] ssh -t [user]@172.16.[IP].$i "echo [password] | sudo -S halt -p"; done
```

## Check USB devices on each VM
After starting all VMs, attach GuestAdditions.iso to all VMs,

```
for i in $(seq 0 15); do sshpass -p [password] ssh -t [user]@172.16.[IP].$i "lsusb | grep Fut"; done
```
