# Wifish #

Wifish is a bunch of small shell scripts to get ride of wicd/NetworkManager.

## License ##

Wifish is released under the MIT Public License

## Description ##

Wifish is two main things:

- wifish-cfg: an iteractive tool to configure/connect to a specific network.

- wifishd: a daemon that scans regulary networks and connects 
to one if it's already configured.

It also installs `wifish` which is a simple wrapper around `sudo wifish-cfg` and a simple init script for wifishd.

## Installation ##

### Dependancies ###

Wifish relies on `dmenu`, `iwlist`, `wpa_supplicant`, 
`iwconfig`, a dhcp client (tested with `dhclient`) and `ifconfig`.

### Make ###

Just run as root:

```
make install
```

## Configuration ##

Some wifish parameters could be configured in ```/etc/wifish/wifish.conf``` (default location).

It's mainly stuff like path to pid files, dhcp client, templates or networks directories.

The configured networks are stored in ```/etc/wifish/networks/```.

## wifishd ##

wifishd is a daemon that connects automaticaly to already configured networks.

### starting wifishd ###

Wifish provides a (too?) simple init script to start or stop wifishd:

```bash
#start wifisihd
/etc/init.d/wifishd start
#stop wifishd
/etc/init.d/wifishd stop
#restart wifishd
/etc/init.d/wifishd restart
#show if it's running or not
/etc/init.d/wifishd status
```

Making wifishd start at boot:

```bash
#on debian
update-rc.d wifishd start
#on gentoo
rc-update add wifishd default
```

## wifish-cfg ##

wifish-cfg is the tool that handles connexion.
 In interactive mode, it proposes the available networks, 
user select one, if the network has never been chosen, 
it interactively configures it (it creates a wpa_supplicant 
configuration file), and it establishes a connexion with this network.

It can be used non interactively with ```-n <netork name>``` option, it simply connects to the given network.
The given network must have been configured previously.

### using wifish-cfg ###

As root, just run:

```
wifish-cfg
```

and select what you need.

### Sudo configuration ###

If you don't trust my script, it should be run as root.

If you trust my script (you shouldn't) you could 
add something like that in your /etc/sudoers:

```
ALL     ALL = NOPASSWD: /usr/sbin/wifish-cfg
```

Now, you can run wifish-cfg as a normal user 

```bash
me@my-host $ sudo wifish-cfg
#or using the provided sudo wrapper:
me@my-host $ wifish
```

### Modifying a network ###

wifish doesn't provide anything for that, you must edit your network file manually inside ```/etc/wifish/networks/```.

It's the same if you want to remove a configured network.

## About templates ##

The template directory is ```/etc/wifish/templates/```.

Template example:

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
You could easily create new templates, wifish will automatically get the variables in your template. ```$_ESSID``` must be present and the variables must be marked by `$_<VARIABLE_NAME>`.

