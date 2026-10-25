# SSH

```conf
Host somewhere
  PubkeyAuthentication yes
  IdentityFile ~/.ssh/id_rsa_yubikey.pub
  HostName somewhere.example
  User your_name
  ForwardAgent yes
  RemoteForward /run/user/XXXX/gnupg/S.gpg-agent /run/user/YYYY/gnupg/S.gpg-agent.extra
  ForwardX11 yes
```
