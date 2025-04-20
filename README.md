# acri-olb

This repository contains scripts and other resources used at the ACRi Room,
primarily developed for integration with the Online Lesson Booking plugin of Wordpress.

The scripts were originally developed by Takefumi MIYOSHI.
Since April 2023, they are maintained by Naoki FUJIEDA.

## How it works

- ACRi Room Servers
  - `server`: Web Server (WordPress / OLB System)
  - `vm-host`: Host Server(s)
    - `client`: Development VM(s) named "vsXYY", where X is the number of host server,
      and YY is the number of development VM for each host
  - `gateway`: Gateway Server, which accepts external SSH connection

1. Web server accepts a reservation and stores its information in the DB
2. Web server retrieves the reservation information of the day (see /acri-room/acri-sql)
3. Web server translates it into JSON format and serves it out to host servers.
4. Host server detects a change of reserved user and restarts the corresponding VM.
5. On a startup of VM, it writes default circuit to its FPGA and modifies its settings.

## server

The scripts in this folder correspond to Step 3 in the "How it works" section.

- `olb-view.rb`: Print the reservation status in JSON format
- `keys-process.rb`: Print the recently updated verification keys in JSON format
- `olb-server.rb`: Launch a local server for `olb-view.rb` and `keys-process.rb`

## vm-host

This folder includes the script corresponding to Step 4.
It also includes some utility scripts for management purposes.

- `restart-vm.rb`: Restart a set of VMs whose reserved users are changed
- `createvms.sh`: Clone a set of VMs from the skel VM

## client

This folder includes the script that runs on a startup of VM (Step 5).
It is registered as a systemd one-shot service.

- `acri-startup.rb`: Write default circuit to FPGA and prepate setting files
- `vm-host-setup.py`: Perform a per-host setup after being cloned from the skel VM

## gateway

Starting from December 2024, Web server also manages users' verification keys.

1. Web server stores verification keys of a user in the DB, through their profile page
2. Web server retrieves the keys that has been recently updated (see /acri-room/acri-sql)
3. Web server translates it into JSON format and serves it out to gateway server.
4. Gateway server detects a change of updated keys and copys them to its key store.
5. Web server updates the time that the keys were set when it receives an ack.

This folder consists of a single script that runs on the gateway server (Step 4 of above).

- `update-keys.py`: Perform key updating process periodically