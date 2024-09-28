# dante-install
Dante server install on Ubuntu 24.04

## Usage

Just three shell commands:

```bash
curl -O https://raw.githubusercontent.com/itcrab/dante-install/master/dante-install.sh
chmod +x openvpn-install.sh
./dante-install.sh
```

## Main goal

Main goal is setup one closed server for using only as socs-proxy-server.

## Features

- Install Dante-server;
- Select IP/PORT server for configuration;
- Select users count for creating;
- Update Ubuntu packages;
- Install some base packages (fail2ban, mc, btop);
- Install ufw firewall and setup it for SSH and Dante ports;
- Provide test connection curl command in the end.

## Auto install feature?

We got it after testing all Ubuntu versions in my list.
