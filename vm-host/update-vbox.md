
# Update VirtualBox

## Prepare

Before updating, stop all VMs running on the host.

```
crontab -e # edit crontab to disable 'start-vm.rb every 2min'.
sh /root/acri-olb/vm-host/stop-all-vms.sh
```

## Update VirtualBox

```
sudo yum install -y VirtualBox-6.1-6.1.16_140961_el7-1.x86_64.rpm
VboxManage extpack uninstall "Oracle VM VirtualBox Extension Pack"
VBoxManage extpack install Oracle_VM_VirtualBox_Extension_Pack-6.1.16.vbox-extpack
```

## Update GuestAddtions in each VM

Attach GuestAdditions.iso to all VMs
```
for i in $(/root/acri-olb/vm-host/all-vms.rb); do VBoxManage storageattach $i --storagectl IDE --port 0 --device 0 --type dvddrive --medium /usr/share/virtualbox/VBoxGuestAdditions.iso; done
```

Revert crontab to enable 'start-vm.rb'
```
crontab -e # edit crontab to enable 'start-vm.rb every 2min'.
```

After starting all VMs, Login to each VM by SSH and execute the update script.

```
for i in $(seq 0 15); do sshpass -p [password] ssh -t [user]@172.16.[IP].$i "echo [password] | sudo -S /root/acri-olb/client/vbox-guest-update.sh"; done
```

After updating GuestAdditions, stop all VMs and remove GuestAdditions.iso

```
crontab -e # edit crontab to disable 'start-vm.rb every 2min'.
sh /root/acri-olb/vm-host/stop-all-vms.sh
for i in $(/root/acri-olb/vm-host/all-vms.rb); do VBoxManage storageattach $i --storagectl IDE --port 0 --device 0 --type dvddrive --medium emptydrive; done
```

Revert crontab to enable 'start-vm.rb'
```
crontab -e # edit crontab to enable 'start-vm.rb every 2min'.
```

## Check USB devices on each VM
After starting all VMs, attach GuestAdditions.iso to all VMs,

```
for i in $(seq 1 15); do sshpass -p [password] ssh -t [user]@172.16.[IP].$i "lsusb | grep Fut"; done
```

