# Set up notes for Red Pitya

## Image preparation

[Image Preparation instructions](https://redpitaya.readthedocs.io/en/latest/quickStart/SDcard/SDcard.html)

1. Download the [latest (2.0) image](https://downloads.redpitaya.com/downloads/Unify/RedPitaya_OS_2.05-37_beta.img.zip).
2. Unzip the image and use (for example) the [balenaEtcher](https://www.balena.io/etcher/) to write the image. 


## Windows Host Setup

Enable Internet Connection Sharing (ICS) on Windows

1. Press Windows + R → type ncpa.cpl → Enter (opens Network Connections).
2. Right-click the interface that has internet access (e.g., Wi-Fi, Ethernet) → click Properties.
3. Go to the Sharing tab.
4. Check "Allow other network users to connect through this computer's Internet connection."
5. In the dropdown, select the Ethernet interface connected to the Red Pitya. Click OK. Windows will now:
    * Enable DHCP on the second interface.
    * Assign itself a static IP (typically 192.168.137.1).
    * Set up NAT routing to share the internet.


In WSL use "Mirrored" networking mode, otherwise, you will not have access to the additional interface from WSL. You can changed that in the "WSL Settings" app.

## Serial Console Connection (optional)

If you want to monitor the boot sequence and debug or set network configuration. Use the serial console. Follow [serial console instructions here](https://redpitaya.readthedocs.io/en/latest/developerGuide/software/console/console/console.html). 

## Networking (optional)

The Red Pitya will use DHCP to obtain an IP address. However, you can also switch to static IP, etc. See [Network Documentation](https://redpitaya.readthedocs.io/en/latest/developerGuide/software/other_info/os/network.html) for details. For example, to set a static IP adress:

1. Edit `/etc/systemd/network/wired.network`

```
[Match]
Name=eth0

[Network]
Address=192.168.1.6/24
```

2. `systemctl restart systemd-networkd`


## Connecting to the Red Pitya

If you are using the standard DHCP configuration, the device will use broadcast DNS and you will be able to access it through it's name, which is printed on the device, e.g. rp-f0d485.local.

Copy your SSH public key to the device:

```bash
ssh-copy-id root@rp-xxxxxx.local`
```

The default password is `root`.

After this you should be able to SSH to the device without password. 

You can also access the webserver of the Red Pitya at http://rp-xxxxxx.local.


## Setting up repos and MaRCoS

There is a simple script that modifies the required files, run it like this:

```bash
./setup.sh --rp-hostname rp-xxxxxx.local
```

Then set up a python virtual environent and install the MaRGE `requirements.txt` and then within that virtual environment:

```
cd MaRGE
python main.py
```