## setup

Add the following in /etc/rc.local

```
mkdir -p /tools
mount -t vboxsf tools -o ro,dmode=777 /tools

(cd /root/acri-olb/client; ruby olb-read.rb)
(cd /root/acri-olb/client; ./cleanfpga.sh)
```

