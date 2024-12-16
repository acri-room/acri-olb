## gateway

Since December 2024, the gateway server has adopted public key authentication
as the default authentication method. Verification keys for each user are
provided through the user profile of the reservation system (i.e. WordPress).

The script periodically fetches recently updated keys and stores them to
`/var/ssh/keys/%u`, where `%u` is the user name, usually starting from `u_`.

## setup

1. In `/etc/ssh/sshd_config`, add `/var/ssh/keys/%u` to the list of
   `AuthorizedKeysFile`, separated by spaces.

2. reload the SSH service.

3. register `python3 /PATH/TO/acri-olb/gateway/update-keys.py` to the root's
   crontab.