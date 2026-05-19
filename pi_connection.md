# Raspberry Pi Connection (SSH)
There are 3 different ways to SSH into a Pi. In order to SSH into a Pi, it must first be connected to your Tailnet. Download the Linux version of Tailscale onto the Pi and any other device that you may need. Once Pi is connected, proceed to the following steps with the Onboarding Computer you are using.


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
- Grant execution permissions if necessary using:
```
chmod +x install_mavlink_router.sh
```
Otherwise,
```
./install_mavlink_router.sh
```
## Mavlink-Router Repo + Raspberry Pi SSH Complete
- Once in VS Code, SSH'd into Pi and in mavlink-router directory:

1. Plug in your Pixhawk and make sure it is on the correct serial port. 

- Confirming correct serial port (in this case, /dev/ttyACM0):
```
ls /dev/ttyACM*
```
- You should see the serial port listed once running the ls command.

2. Run mavlink-router

- To run the mavlink router, run in terminal:
```
mavlink-routerd -c /etc/mavlink-router/main.conf
```

- Additionally, to view config file:
```
cat /etc/mavlink-router/main.conf
```

3. Open Mission Planner on your Laptop/Onboarding Computer
- Navigate to the top right corner, set drop down to UDP
- Port 14550
- Click Connect

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

## Simplified Running
- In VS Code terminal, run:
```bash
mavlink-routerd -c /etc/mavlink-router/main.conf
```

Then, in Mission Planner: 

*UDP → port 14550 → Connect*.
