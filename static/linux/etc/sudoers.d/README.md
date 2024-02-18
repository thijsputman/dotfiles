# `📂 sudoers.d`

To apply the settings in this folder safely, use `visudo` and manually copy the
file's contents into the editor:

```shell
sudo visudo -f /etc/sudoers.d/10-pwfeedback
sudo visudo -f /etc/sudoers.d/80-yubikey
```
