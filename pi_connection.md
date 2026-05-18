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

- Then, to open in VS Code, code .
- To end connection, type "exit"

## 2. Through VS Code
- Open VS Code & do CTRL+SHIFT+P
- Remote-SSH: Connect to Host
- Add IP of new device or select previously added device
- Open a new VS Code window with code .

## 3. Through RealVNC Viewer
- Launch RealVNC Viewer & add a new device or search
- Connect via IP Address

## Additional Notes
- Tailscale must be live with all devices on same network and connected for this to work.
