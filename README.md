# dante-install
Dante server install on Ubuntu 24.04 22.04 20.04

## Usage

Just three shell commands:

```bash
curl -O https://raw.githubusercontent.com/itcrab/dante-install/master/dante-install.sh
chmod +x dante-install.sh
./dante-install.sh
```

## Main goal

Main goal is setup one closed server for using only as socs-proxy-server.

## Features

- Install Dante-server;
- Select IP/PORT server for configuration;
- Select users count for creating;
- Update Ubuntu packages;
- Install some base packages (fail2ban, mc, btop):
  - Ubuntu 20.04: E: Unable to locate package btop.
- Emable hard security feature:
  - fail2ban config.
- Install ufw firewall and setup it for SSH and Dante ports;
- Provide test connection curl command in the end;
- Support last three LTS Ubuntu versions.

## Auto install feature?

Coming soon...
