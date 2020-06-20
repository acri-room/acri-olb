import sys
import os

if len(sys.argv) != 3:
    print("usage:", sys.argv[0], " name ipaddr/dhcp")
    print(" example:", sys.argv[0], "vs001", "172.16.4.1/16")
    print(" example:", sys.argv[0], "skel0", "dhcp")
    sys.exit(0)

host = sys.argv[1]
ipaddr = sys.argv[2]

print("setup this host {} {}".format(host, ipaddr))
os.system("hostname {}".format(host))

with open("/etc/hostname", mode='w') as f:
    f.write(host)

with open("/etc/hosts", mode='w') as f:
    f.write("127.0.0.1 localhost\n")
    f.write("127.0.1.1 {}\n".format(host))
    f.write("\n")
    f.write("# The following lines are desirable for IPv6 capable hosts\n")
    f.write("::1     ip6-localhost ip6-loopback\n")
    f.write("fe00::0 ip6-localnet\n")
    f.write("ff00::0 ip6-mcastprefix\n")
    f.write("ff02::1 ip6-allnodes\n")
    f.write("ff02::2 ip6-allrouters\n")

with open("/etc/netplan/50-cloud-init.yaml", mode='w') as f:
    f.write("# This file is generated from information provided by the datasource.  Changes\n")
    f.write("# to it will not persist across an instance reboot.  To disable cloud-init's\n")
    f.write("# network configuration capabilities, write a file\n")
    f.write("# /etc/cloud/cloud.cfg.d/99-disable-network-config.cfg with the following:\n")
    f.write("# network: {config: disabled}\n")
    f.write("network:\n")
    f.write("    ethernets:\n")
    f.write("        enp0s3:\n")
    if ipaddr == "dhcp":
        f.write("            dhcp4: true\n")
    else:
        f.write("            dhcp4: no\n")
        f.write("            addresses: [{}]\n".format(ipaddr))
        f.write("            gateway4: 172.16.1.1\n")
        f.write("            nameservers:\n")
        f.write("                search: [acri.c.titech.ac.jp]\n")
        f.write("                addresses: [172.16.2.1,131.112.125.58]\n")
    f.write("    version: 2\n")

os.system("rm -v /etc/ssh/ssh_host_*key*")
os.system("dpkg-reconfigure openssh-server")
