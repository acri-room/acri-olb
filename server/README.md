## firewall setting
see and execute setup.sh

## start server automatically

Add the following into /etc/rc.local

```
(cd /root/acri-olb/server; ./olb-server.rb &)
```

And then, set executable-bit to /etc/rc.local

```
chmod 755 /etc/rc.d/rc.local
```
