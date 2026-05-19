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

- To open config file, in VS Code terminal run :
```
code /etc/mavlink-router/main.conf
```

## MAVLink Router Setup

Flight controller telemetry is routed from the Pixhawk to Mission Planner over Tailscale VPN using mavlink-router.

Flow: Pixhawk --[USB/UART]--> Raspberry Pi [mavlink-router] --[UDP/Tailscale]--> Laptop [Mission Planner]

## Installation
- Begin by cloning and installing Mavlink-Router repository. 
- The original commands, if needed, are:
```bash
git clone https://github.com/mavlink-router/mavlink-router.git
cd mavlink-router
git submodule update --init --recursive
meson setup build .
ninja -C build
sudo ninja -C build install
```
- However, install_mavlink_router.sh is a shell script containing all necessary commands to install the Mavlink-Router repository onto a Raspberry Pi.

- Confirming correct serial port (in this case, /dev/ttyACM0):
```
ls /dev/ttyACM*
```
- Viewing config file:
```
cat /etc/mavlink-router/main.conf
```
## Config File 
- Stored where the mavlink-router looks by default:
`/etc/mavlink-router/main.conf`

```ini
[General]
TcpServerPort=0 // Disables TCP, Tailscale mainly needs UDP
MavlinkDialect=ardupilotmega // Makes sense since running ardupilot firmware (MP)

// Ingest the serial port
[UartEndpoint FC]
Device=/dev/ttyACM0 // The serial port of the Pixhawk (FC)
Baud=57600 // Default serial speed ArduPilot/Pixhawk uses

// Route it over Tailscale
[UdpEndpoint Laptop]
Mode=Normal
Address=<LAPTOP_TAILSCALE_IP>
Port=14550 // Standard mavlink port MP listens on 
```

## Running
- In VS Code terminal, run:
```bash
mavlink-routerd -c /etc/mavlink-router/main.conf
```

Then, in Mission Planner: 

*UDP → port 14550 → Connect*.