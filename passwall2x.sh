#!/bin/bash
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
CYAN='\033[0;36m'
GRAY='\033[0;37m'
NC='\033[0m' # No Color

echo "Running as root..."
sleep 2
clear

uci set network.wan.peerdns="0"

uci set network.wan6.peerdns="0"

uci set network.wan.dns='1.1.1.1'

uci set network.wan6.dns='2001:4860:4860::8888'

uci commit system

uci commit network

uci commit

/sbin/reload_config

SNNAP=`grep -o SNAPSHOT /etc/openwrt_release | sed -n '1p'`

if [ "$SNNAP" == "SNAPSHOT" ]; then

echo -e "${RED} SNAPSHOT Version is not supported ! ${NC}"

exit 1

 else
           
echo -e "${GREEN} Updating Packages ... ${NC}"

fi

### Update Packages ###

opkg update

### Add Src ###

wget -O passwall.pub https://master.dl.sourceforge.net/project/openwrt-passwall-build/ipk.pub

opkg-key add passwall.pub

>/etc/opkg/customfeeds.conf

read release arch << EOF
$(. /etc/openwrt_release ; echo ${DISTRIB_RELEASE%.*} $DISTRIB_ARCH)
EOF
for feed in passwall_luci passwall_packages passwall2; do
  echo "src/gz $feed https://master.dl.sourceforge.net/project/openwrt-passwall-build/releases/packages-$release/$arch/$feed" >> /etc/opkg/customfeeds.conf
done

### Install package ###

opkg update
sleep 3
opkg remove dnsmasq
sleep 3
opkg install dnsmasq-full
sleep 2
opkg install wget-ssl
sleep 1
opkg install unzip
sleep 2
opkg install luci-app-passwall2
sleep 3
opkg install kmod-nft-socket
sleep 2
opkg install kmod-nft-tproxy
sleep 2
opkg install ca-bundle
sleep 1
opkg install kmod-inet-diag
sleep 1
opkg install kernel
sleep 1
opkg install kmod-netlink-diag
sleep 1
opkg install kmod-tun
sleep 1
opkg install ipset

>/etc/banner

echo "    ___    __  ___________  __  ______  __________ ___________   __
   /   |  /  |/  /  _/ __ \/ / / / __ \/ ___/ ___// ____/  _/ | / /
  / /| | / /|_/ // // /_/ / /_/ / / / /\__ \\__ \ / __/  / //  |/ /
 / ___ |/ /  / // // _  _/ __  / /_/ /___/ /__/ / /____/ // /|  /
/_/  |_/_/  /_/___/_/ |_/_/ /_/\____//____/____/_____/___/_/ |_/                                                                                                
telegram : @AmirHosseinTSL" >> /etc/banner

sleep 1


RESULT5=`ls /etc/init.d/passwall2`

if [ "$RESULT5" == "/etc/init.d/passwall2" ]; then

echo -e "${GREEN} Passwall.2 Installed Successfully ! ${NC}"

 else

 echo -e "${RED} Can not Download Packages ... Check your internet Connection . ${NC}"

 exit 1

fi


DNS=`ls /usr/lib/opkg/info/dnsmasq-full.control`

if [ "$DNS" == "/usr/lib/opkg/info/dnsmasq-full.control" ]; then

echo -e "${GREEN} dnsmaq-full Installed successfully ! ${NC}"

 else
           
echo -e "${RED} Package : dnsmasq-full not installed ! (Bad internet connection .) ${NC}"

exit 1

fi


####install_xray
opkg install xray-core

sleep 2

RESULT=`ls /usr/bin/xray`

if [ "$RESULT" == "/usr/bin/xray" ]; then

echo -e "${GREEN} XRAY : OK ! ${NC}"

 else

 echo -e "${RED} XRAY installation failed. Please check your storage space. ${NC}"

fi


uci set passwall2.@global_forwarding[0]=global_forwarding
uci set passwall2.@global_forwarding[0].tcp_no_redir_ports='disable'
uci set passwall2.@global_forwarding[0].udp_no_redir_ports='disable'
uci set passwall2.@global_forwarding[0].tcp_redir_ports='1:65535'
uci set passwall2.@global_forwarding[0].udp_redir_ports='1:65535'
uci set passwall2.@global[0].remote_dns='8.8.4.4'

uci commit passwall2


uci commit

echo -e "${YELLOW}** Installation Completed ** ${ENDCOLOR}"
echo -e "${MAGENTA} Made With Love By : AmirHossein ${ENDCOLOR}"

rm passwall2x.sh

rm passwallx.sh

/sbin/reload_config
