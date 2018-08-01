#!/bin/bash
RED='\033[0;31m'
NC='\033[0m' # No Color
(( EUID != 0 )) && exec sudo -- "$0" "$@"
read -r -p "This will install SoftEther to your server. Are you sure you want to continue? [y/N] " response
case $response in
[yY][eE][sS]|[yY])
echo "Updating the system first..."
apt update && apt upgrade -y && apt install checkinstall build-essential -y
echo "Downloading last stable release: 4.27"
sleep 2
wget  -O softether-vpn-4.27.tar.gz http://softether-download.com/files/softether/v4.27-9668-beta-2018.05.29-tree/Linux/SoftEther_VPN_Server/64bit_-_Intel_x64_or_AMD64/softether-vpnserver-v4.27-9668-beta-2018.05.29-linux-x64-64bit.tar.gz
tar -xzf softether-vpn-4.27.tar.gz
cd vpnserver
echo -e "${RED}Please press 1 for all the following questions.${NC}"
sleep 1
make
cd ..
mv vpnserver /usr/local/
chmod 600 /usr/local/vpnserver/*
chmod 700 /usr/local/vpnserver/vpncmd
chmod 700 /usr/local/vpnserver/vpnserver
echo '#!/bin/sh
# description: SoftEther VPN Server
### BEGIN INIT INFO
# Provides:          vpnserver
# Required-Start:    $local_fs $network
# Required-Stop:     $local_fs
# Default-Start:     2 3 4 5
# Default-Stop:      0 1 6
# Short-Description: softether vpnserver
# Description:       softether vpnserver daemon
### END INIT INFO
DAEMON=/usr/local/vpnserver/vpnserver
LOCK=/var/lock/subsys/vpnserver
test -x $DAEMON || exit 0
case "$1" in
start)
$DAEMON start
touch $LOCK
;;
stop)
$DAEMON stop
rm $LOCK
;;
restart)
$DAEMON stop
sleep 3
$DAEMON start
;;
*)
echo "Usage: $0 {start|stop|restart}"
exit 1
esac
exit 0' > /etc/init.d/vpnserver
echo "System daemon created. Registering changes..."
sleep 2
chmod 755 /etc/init.d/vpnserver
update-rc.d vpnserver defaults
echo -e "${RED}SoftEther VPN Server should now start as a system service from now on. To check status type 'systemctl status vpnserver'${NC}"
systemctl start vpnserver
echo -e "${RED}Now opening ports 443/TCP, 1194/TCP & 5555/TCP for basic usage."
ufw allow 443,1194,5555/tcp
echo -n "Do you plan to use L2TP/IPsec on this server (y/n)? If so, I will open those ports for you. If you use GCP or other Cloud Platforms, you may need to go to your dashboard and allow these ports as well.${NC}"
read answer
if [ "$answer" != "${answer#[Yy]}" ] ;then
  ufw allow 500,1701,4500/udp
else
  echo -e "Alright, no ports for L2TP/IPsec were opened."
fi
esac
