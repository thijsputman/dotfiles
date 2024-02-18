# `📂 NetworkManager/dispatcher.d`

## Exclusive WiFi-/wired-connection

Used on some Raspberry Pi-devices that can be connected via both a wired- and
WiFi-connection.

This script disables the WiFi radio when a wired-connection is up; ensuring the
device is only connected to the network with a single IP-address.
