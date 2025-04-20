## ACRi-OLB Server Scripts
In the Web server, the internal server script (`olb-server.rb`) is registered as a systemd service (`olb-server.service`).
The server launches the following scripts:

- `olb-view.rb`: Print the reservation status in JSON format
- `keys-process.rb`: Print the recently updated verification keys in JSON format

The `olb-view.rb` script is mainly called from VM host servers (`../vm-host`) to restart VMs according to the reservation status.
The `keys-process.rb` script is called from the gateway server (`../gateway`) to copy recently updated verification keys to the gateway.

Some deprecated scripts have been removed from the repository on April 20, 2025.