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
- Begin by cloning this repository onto the Pi:
```bash
git clone https://github.com/Siya-Bhadu/mavlink-router.git
cd mavlink-router
```

- `install_mavlink_router.sh` is a shell script containing all necessary commands to install mavlink-router onto a Raspberry Pi.
- Grant execution permissions if necessary using:
```bash
chmod +x install_mavlink_router.sh
```
Then run:
```bash
./install_mavlink_router.sh
```

- The manual commands, if needed, are:
```bash
git clone https://github.com/mavlink-router/mavlink-router.git
cd mavlink-router
git submodule update --init --recursive
meson setup build . -Dsystemdsystemunitdir=/usr/lib/systemd/system
ninja -C build
sudo ninja -C build install
```

Verify the install worked:
```bash
mavlink-routerd --version
```
You should see something like:
mavlink-router version v4-16-g2362c62

---

## Config File
The config file tells mavlink-router where to read data from (Pixhawk) and where to send it (your laptop over Tailscale). It is stored where mavlink-router looks by default:
`/etc/mavlink-router/main.conf`

Create it with:
```bash
sudo mkdir -p /etc/mavlink-router
sudo nano /etc/mavlink-router/main.conf
```

Paste the following, replacing `<LAPTOP_TAILSCALE_IP>` with your laptop's Tailscale IP:
```ini
[General]
TcpServerPort=0
MavlinkDialect=ardupilotmega

# Ingest the serial port (Pixhawk)
[UartEndpoint FC]
Device=/dev/ttyACM0
Baud=57600

# Route it out over Tailscale
[UdpEndpoint Laptop]
Mode=Normal
Address=<LAPTOP_TAILSCALE_IP>
Port=14550
```
Save with `Ctrl+X` → `Y` → `Enter`.

To find your laptop's Tailscale IP run on your laptop:
```bash
tailscale ip -4
```

### What each value means
| Value | Meaning |
|---|---|
| `TcpServerPort=0` | Disables TCP, Tailscale only needs UDP |
| `MavlinkDialect=ardupilotmega` | Pixhawk running ArduPilot firmware (Mission Planner) |
| `Device=/dev/ttyACM0` | The serial port Linux assigns to the Pixhawk over USB |
| `Baud=57600` | Default serial speed ArduPilot/Pixhawk uses on telemetry port |
| `Mode=Normal` | Pi pushes packets out to the laptop (client mode) |
| `Address=...` | Your laptop's Tailscale IP —> where to send the data |
| `Port=14550` | Standard MAVLink UDP port Mission Planner listens on |

- Combined simple view:

```ini
[General]
TcpServerPort=0 // Disables TCP, Tailscale mainly needs UDP
MavlinkDialect=ardupilotmega // Makes most sense since running ardupilot firmware (MP)

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
---

## Mavlink-Router Repo + Raspberry Pi SSH Complete
Once in VS Code, SSH'd into Pi and in the mavlink-router directory:

### 1. Confirm Tailscale is running
```bash
tailscale status
```
Your laptop should appear in the list. If Tailscale isn't running:
```bash
sudo tailscale up
```

### 2. Plug in your Pixhawk and confirm the correct serial port
```bash
ls /dev/ttyACM*
```
You should see the serial port listed. Confirm which one is the Pixhawk by checking for data:
```bash
sudo cat /dev/ttyACM0
```
If you see a stream of garbled characters, that's raw MAVLink binary data —> that's the correct port. If blank, hit `Ctrl+C` and try `ttyACM1`. Update the config file if your port differs from `/dev/ttyACM0`.

### 3. Run mavlink-router
```bash
mavlink-routerd -c /etc/mavlink-router/main.conf
```
You should see:
mavlink-router version v4-16-g2362c62
Opened UART [4]FC: /dev/ttyACM0
UART [4]FC: speed = 57600
Opened UDP Client [5]Laptop: <LAPTOP_TAILSCALE_IP>:14550

To view the config file:
```bash
cat /etc/mavlink-router/main.conf
```

### 4. Open Mission Planner on your Laptop
- Navigate to the top right corner, set dropdown to **UDP**
- Port **14550**
- Click **Connect**
- Enter **14550** in the Listen Port dialog → click **OK**

You should see the HUD come alive with live telemetry from the Pixhawk.

---

## Restarting the Connection
Every time you want to use this setup:
1. SSH into the Pi
2. Confirm Tailscale is running: `tailscale status`
3. Confirm Pixhawk is plugged in: `ls /dev/ttyACM*`
4. Run mavlink-router: `mavlink-routerd -c /etc/mavlink-router/main.conf`
5. Connect Mission Planner: **UDP → 14550 → Connect**

---

## Shutting Down
1. Stop mavlink-router: `Ctrl+C`
2. Shut down the Pi safely: `sudo shutdown now`
3. Wait for the green LED to stop blinking
4. Unplug the Pixhawk USB cable

---

## Troubleshooting
| Problem | Fix |
|---|---|
| `/dev/ttyACM0` not found | Pixhawk not plugged in, or try `ttyACM1` |
| Mission Planner won't connect | Check Tailscale is active on both devices |
| No data in Mission Planner | Check baud rate matches FC setting (`SERIAL1_BAUD`) |
| Permission denied on serial port | `sudo usermod -aG dialout $USER` then reboot |
| mavlink-router not found | Re-run install, verify with `mavlink-routerd --version` |
| Tailscale offline on Pi | SSH via local IP first, then `sudo tailscale up` |
