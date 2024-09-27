#!/bin/bash

# https://github.com/itcrab/dante-install

# Dante - A free SOCKS server :: Installer
# Tested on Ubuntu 24.04

echo "Dante::installer: please give answers for some questions."
echo "========================================================="

read -p "Dante::installer: do you need to install Dante-server? [y/n] " dante_install
if [ "${dante_install}" != "y" ]; then
  echo "Dante::installer: install Dante server is stopped now by your choice."
  exit 1
fi

DANTE_SERVER_IP=$(hostname --ip-address)
read -p "Dante::installer: Dante server IP address ${DANTE_SERVER_IP} is correct? [y/n] " ip_server
if [ "${ip_server}" = "n" ]; then
  read -p "Dante::installer: Please enter right IP address (like: 83.101.31.158): " DANTE_SERVER_IP
  echo "Dante::installer: using entered IP address: ${DANTE_SERVER_IP}."
else
  echo "Dante::installer: using auto calculated IP address: ${DANTE_SERVER_IP}."
fi

DANTE_SERVER_PORT="1080"
read -p "Dante::installer: Dante server PORT ${DANTE_SERVER_PORT} is correct? [y/n] " port_server
if [ "${port_server}" = "n" ]; then
  read -p "Please enter right Dante server PORT (like: 601080): " DANTE_SERVER_PORT
  echo "Dante::installer: using entered Dante server PORT: ${DANTE_SERVER_PORT}."
else
  echo "Dante::installer: using default Dante server PORT: ${DANTE_SERVER_PORT}."
fi

read -p "Dante::installer: do you need to create some users for Dante? [1] " dante_users_count
if [ "${dante_users_count}" = "" ]; then
  dante_users_count=1
fi

read -p "Dante::installer: do you need to update Ubuntu packages? [y/n] " update_ubuntu
read -p "Dante::installer: do you need to install base packages (fail2ban, mc, btop)? [y/n] " fail2ban_mc_install
read -p "Dante::installer: do you need to install ufw (firewall)? [y/n] " ufw_install
echo "========================================================="

if [ "${update_ubuntu}" = "y" ] || [ "${fail2ban_mc_install}" = "y" ] || [ "${dante_install}" = "y"] || [ "${ufw_install}" = "y"]; then
  echo "Dante::installer: update list Ubuntu packages."
  apt update
fi
echo "========================================================="

if [ "${update_ubuntu}" = "y" ]; then
  echo "Dante::installer: upgrade Ubuntu packages."
  apt upgrade -y
else
  echo "Dante::installer: skipping upgrade Ubuntu packages."
fi
echo "========================================================="

if [ "${fail2ban_mc_install}" = "y" ]; then
  echo "Dante::installer: install fail2ban, mc, btop."
  apt install -y fail2ban mc btop
else
  echo "Dante::installer: skipping install fail2ban, mc, btop."
fi
echo "========================================================="

if [ "${dante_install}" = "y" ]; then
  echo "Dante::installer: install Dante-server."
  apt install dante-server
  systemctl --no-pager status danted.service  # failed start
  echo "Dante::installer: Dante-server is already installed but is failed running."
  echo "Dante::installer: this is ok - we fixed it right now."

  echo "Dante::installer: fixing Dante config."
  cp /etc/danted.conf /etc/danted.conf.old
  echo "# Settings from https://www.8host.com/blog/kak-nastroit-proksi-server-dante/
logoutput: syslog
user.privileged: root
user.unprivileged: nobody

# The listening network interface or address.
internal: 0.0.0.0 port=${DANTE_SERVER_PORT}

# The proxying network interface or address.
#external: eth0  # fix on server
external: ${DANTE_SERVER_IP}

# socks-rules determine what is proxied through the external interface.
socksmethod: username

# client-rules determine who can connect to the internal interface.
clientmethod: none

client pass {
    from: 0.0.0.0/0 to: 0.0.0.0/0
}

socks pass {
    from: 0.0.0.0/0 to: 0.0.0.0/0
}" > /etc/danted.conf

  if [[ $dante_users_count =~ ^[0-9]+$ ]]; then
    echo "Dante::installer: create users for Dante."
    for dante_user_id in $(seq 1 $dante_users_count); do
      echo "Dante::installer: create user #${dante_user_id} for Dante."

      read -p "Dante::installer: please enter user name (like: Ivan): " dante_user_name
      useradd -r -s /bin/false ${dante_user_name}

      example_password=$(tr -dc 'A-Za-z0-9!?#@%=' < /dev/urandom | head -c 16)
      echo "Please enter user password (like: ${example_password}):"
      passwd ${dante_user_name}
    done
  else
    echo "stop install"
    exit 1
  fi

  systemctl restart danted.service
  echo "Dante::installer: Dante-server installed and already run right now."
else
  echo "Dante::installer: skipping install Dante-server."
fi
echo "========================================================="

if [ "${ufw_install}" = "y" ]; then
  echo "Dante::installer: install ufw."
  apt install -y ufw

  ufw default deny incoming
  echo "Dante::installer: ufw: deny all incoming."

  ufw allow ssh
  echo "Dante::installer: ufw: allow SSH."

  ufw allow ${DANTE_SERVER_PORT}
  echo "Dante::installer: ufw: allow Dante server."

  sed -i -e 's/IPV6=yes/IPV6=no/g' /etc/default/ufw
  echo "Dante::installer: ufw: disable IPv6 support."

  echo "Dante::installer: ufw: enable?"
  ufw enable
else
  echo "Dante::installer: skipping install ufw."
fi
echo "========================================================="

echo "Dante::installer: all works is done!"
echo ""
echo "Dante::installer: you can check Dante server working like this:"
echo "curl -v -x socks5://user_name:user_pass@${DANTE_SERVER_IP}:${DANTE_SERVER_PORT} http://www.google.com/"
