# Wifish #

Wifish is two small scripts to get ride of wicd/NetworkManager.

## License ##

Wifish is released under the MIT Public License

## Description ##

Wifish is two main things:

- wifish-cfg: a command that handles connexion.
 in interactive mode, it proposes the available networks, 
user select one, if the network has never been chosen, 
it interactively configures it (it creates a wpa_supplicant 
configuration file), and it establishes a connexion with this network.

- wifishd: a daemon that scans regulary networks and connects 
to one if it's already configured.

It also installs `wifish` which is a simple wrapper arround `sudo wifish-cfg`.

## Installation ##

Just run as root:

```
make install
```

## Configuration ##

Some parameters could be configured in ```/etc/wifish/wifish.conf``` (default location).

The configured networks are stored in ```/etc/wifish/networks/```.

## Template ##

The template directory is ```/etc/wifish/templates/```.

Template format is the following:

```
ctrl_interface=/var/run/wpa_supplicant
network={
    ssid="$_ESSID"
    key_mgmt=WPA-EAP
    eap=TTLS
    identity="$_IDENTITY"
    anonymous_identity="anonymous"
    password="$_PASSWORD"
    phase2="auth=PAP"
}
```

The Variables are marked by `$_<VARIABLE_NAME>`

## Dependancies ##

Wifish relies on `dmenu`, `iwlist`, `wpa_supplicant`, 
`iwconfig`, a dhcp client (test with `dhclient`) and `ifconfig`.

## Sudo configuration ##

If you don't trust my scrit, it should be run as root.

If you trust my script (you shouldn't) you could 
add something like that in your /etc/sudoers:

```
ALL     ALL = NOPASSWD: /usr/sbin/wifish-cfg
```

Now, you can run wifish as a normal user

```bash
me@my-host # wifish
```
