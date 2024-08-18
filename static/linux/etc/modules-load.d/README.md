# `systemd-modules-load`

As of WSL2 `2.3.11`, the switch was made from a monolithic `5.15`-kernel to a
module-based `6.6`-kernel.

In order to use (for example) USB-devices via `usbip`, additional kernel
module(s) need to be loaded on boot. By default, `systemd-modules-load` is
disabled on virtualised systems (like WSL2).

To remedy this, comment out `ConditionVirtualization=!container` in
`systemd-modules-load`'s configuration and restart the system:

```shell
sudo nano /lib/systemd/system/systemd-modules-load.service
sudo reboot
```

Configurations in `📂 /etc/modules-load.d` should now be picked up and the
requested modules should automatically be loaded on boot.

## Virtual USB host controller (`vhci_hcd`)

In order to use USB devices forwarded via `usbip`, the `vhci_hcd`-module should
be loaded.
