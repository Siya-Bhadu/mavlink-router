# Raspberry Pi Connection (SSH)
There are 3 different ways to SSH into a Pi.


## 1. Through Windows Powershell
- Open Terminal into Windows Powershell

```
tailscale status
```
- Find the device on your Tailnet that you want to SSH into. In this case, it is a Raspberry Pi.

```
ssh [username]@[hostname-or-IP-address]
```
Example: ssh uav2@100.118.221.52

