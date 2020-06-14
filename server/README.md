## firewall setting

see and execute setup.sh

## setup olb-monitor.rb

olb-monitor.rb generates local DB to valid users for each VM. The script should run every 15min.

```
crontab crontab
```

After that, check crontab entry by the following.

```
crontab -l
```

## start server automatically

Add the following into /etc/rc.local

```
(cd /root/acri-olb/server; ./olb-server.rb &)
```

And then, set executable-bit to /etc/rc.local

```
chmod 755 /etc/rc.d/rc.local
```
