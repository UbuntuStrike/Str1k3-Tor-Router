#!/bin/bash
#
# Str1k3 TOR Hotspot: On demand Debian Linux (Tor) Hotspot setup tool
# This code is designed to automate setip to implement Tor router to keep you safe online!
# Tor is only as safe as the user and I recomend doing some research on: Dns leaks, Stun-requests ,WebRTC etc.
# TOR, PRIVOXY, MACCHANGER, DNSMASQ, 
# Coded By: N053LF @knoself (on Twitter) from Ubun7uStr1k3

export YELLOW='\033[1;93m'
export GREEN='\033[1;92m'
export RED='\033[1;91m'
export RESETCOLOR='\033[1;00m'


about(){
echo -e "\n$YELLOW----------- Str1k3 Hotspot Tor Router ---------------\n" $RESETCOLOR
sleep 7
}

# update stystem

update(){
echo -e "\n$RED Is your system up to date? $YELLOW Y $RED or $YELLOW N : " $RESETCOLOR
read answer
if [ $answer == "N" ] || [ $answer == "n" ]
then
apt-get update && apt-get upgrade
else
echo -e "\n$GREEN System is up to date" $RESETCOLOR
fi
sleep 1
}

# install stystem requirements

requirements(){
echo -e "\n$RED Have you installed the required packages yet? $YELLOW Y $RED or $YELLOW N : " $RESETCOLOR
read answer
if [ $answer == "N" ] || [ $answer == "n" ]
then
apt-get -y install tor dnsmasq hostapd isc-dhcp-server privoxy net-tools macchanger libssl-dev
else
echo -e "\n$GREEN ALL requirements statisfied" $RESETCOLOR
fi
sleep 1
}

# Identify Interfaces

id_iface(){
echo -e "\n$YELLOW BELOW ARE YOUR INTERFACES..$RED ETHERNET LOOKS LIKE: $YELLOW eth0 or en55p $RED AND WIFI LOOKS LIKE $YELLOW wlan0 or wl56p $RED(similar to those)"$RESETCOLOR
ls /sys/class/net -I lo
}

# set ethernet interface variable

set_ether(){
echo -e "$YELLOW"
read -p " set your ethernet interface as listed above:" -e eth
}

# set wireless interface variable

set_wifi(){
read -p " set your wireless interface as listed above:" -e wlan
}


mac_eth0(){

echo -e "\n$GREEN Spoofing Ethernet Mac Address...\n"
	rfkill unblock all
	sleep 3
	sudo service NetworkManager stop
	sleep 1
	echo -e "$GREEN ethernet MAC address:\n"$GREEN
	sleep 1
	sudo ifconfig $eth down
	sleep 1
	sudo macchanger -a $eth
	sleep 1
	sudo ifconfig $eth up
	sleep 1
	sudo service NetworkManager start
	echo -e "\n$GREEN Mac Address Spoofing$GREEN [ON]"$RESETCOLOR
	sleep 5 
	rfkill unblock all
}

# change wlan0 mac

mac_wlan0(){
echo -e "\n$GREEN Spoofing WiFi Mac Address...\n"
	rfkill unblock all
	sleep 3
	sudo service NetworkManager stop
	sleep 1
	echo -e "$GREEN wireless MAC address:\n"$GREEN
	sleep 1
	sudo ifconfig $wlan down
	sleep 1
	sudo macchanger -a $wlan
	sleep 1
	rfkill unblock all
	sleep 1
	sudo ifconfig $wlan up
	sleep 1
	sudo service NetworkManager start
	echo -e "\n$GREEN Mac Address Spoofing$GREEN [ON]"$RESETCOLOR
	sleep 5
	rfkill unblock all
} 

#stop macchanger eth0

ethmac_stop(){
echo -e "\n$GREEN Restoring Mac Address on Ethernet...\n"
	rfkill unblock all
	sleep 3
	sudo service NetworkManager stop
	sleep 1
	echo -e "$GREEN ethernet MAC address:\n"$GREEN	
	sleep 1
	sudo ifconfig $eth down
	sleep 1
	sudo macchanger -p $eth
	sleep 1
	sudo ifconfig $wlan up
	sleep 1
	sudo service NetworkManager start
	sleep 1
	echo -e "\n$GREEN Mac Address Spoofing$RED [OFF]"$RESETCOLOR
	rfkill unblock all
	sleep 5
}

# wifi macchanger stop
wmac_stop(){
echo -e "\n$GREEN Restoring Mac Address on WiFi...\n"
	rfkill unblock all
	sleep 3
	sudo service NetworkManager stop
	sleep 1
	echo -e "$GREEN wireless MAC address:\n"$GREEN	
	sleep 1
	sudo ifconfig $wlan down
	sleep 1
	sudo macchanger -p $wlan
	sleep 1
	sudo ifconfig $wlan up
	sleep 1
	sudo service NetworkManager start
	sleep 1
	echo -e "\n$GREEN Mac Address Spoofing$RED [OFF]"$RESETCOLOR
	rfkill unblock all
	sleep 5 
}


# edit dhcpd.conf

edit_dhcpd(){
echo -e "\n$RED Replacing dhcp.conf, original saved at /etc/dhcp/dhcpd.conf.bak" $RESETCOLOR
cp /etc/dhcp/dhcpd.conf /etc/dhcp/dhcpd.conf.bak
cp dhcpd.conf /etc/dhcp/dhcpd.conf
sleep 1
}

# edit isc-dhcp-server

edit_isc_dhcp_server(){

cp /etc/default/isc-dhcp-server /etc/default/isc-dhcp-server.bak
cp isc-dhcp-server /etc/default/isc-dhcp-server
}

# bring down wifi

Wlan_down(){
ifconfig $wlan down
}


# edit interfaces

edit_interfaces(){
echo -e "\n$RED Replacing interfaces, original saved at /etc/network/interfaces.bak" $RESETCOLOR
sleep 1
cp /etc/network/interfaces /etc/network/interfaces.bak
cat > /etc/network/interfaces << EOL
auto lo

iface lo inet loopback 
iface $eth inet dhcp

allow-hotplug $wlan

iface $wlan inet static
 address 192.168.42.1
 netmask 255.255.255.0
EOL
}

# wifi up set ip

wlan_up(){
ifconfig $wlan 192.168.42.1
sleep 2
}

# set ssid
set_ssid(){
echo -e "$YELLOW"
read -p " set your router name:" -e name
}

# set password
set_pass(){
read -p " set your password (minimum 8 characters!):" -e pass 
}
# show ssid and pass
cred_show(){
echo -e "\n$YELLOW################################################\n"
echo -e "$RED   You've specified following values:"
echo -e "\n$YELLOW*************************************************\n"
echo -e "$GREEN Router name:$YELLOW $name"
echo -e "$GREEN Password:$YELLOW $pass"
echo -e "\n$GREEN##### DAMN IT FEELS GOOD TO BE A GANGSTER! #####\n" $RESETCOLOR
sleep 5
}

# set hostapd values

set_hostapd_conf(){
echo -e "\n$RED Setting hostapd values, original at /etc/hostapd/hostapd.conf.bak " $RESETCOLOR
cp /etc/hostapd/hostapd.conf /etc/hostapd/hostapd.conf.bak
sleep 1

cat > /etc/hostapd/hostapd.conf << EOL
interface=$wlan
driver=nl80211
ssid=$name
#ieee80211n=1
hw_mode=g
channel=6
macaddr_acl=0
auth_algs=1
ignore_broadcast_ssid=0
wpa=2
wpa_passphrase=$pass
wpa_key_mgmt=WPA-PSK
wpa_pairwise=CCMP
wpa_group_rekey=86400
wmm_enabled=1
EOL
}

# hostapd daemon config

set_daemon(){
echo -e "\n$GREEN Setting hostapd Daemon" $RESETCOLOR
sed -i "s/#DAEMON_OPTS=\"\"/DAEMON_OPTS=\"\/etc\/hostapd\/hostapd.conf\"/g" /etc/default/hostapd
sleep 2
#sed -i "s/#DAEMON_CONF=\"\"/DAEMON_CONF=\"\/etc\/hostapd\/hostapd.conf\"/g" /etc/default/hostapd
}

# enable ipv4 forwarding

ipv4_forward(){
sed -i "s/#net.ipv4.ip_forward/net.ipv4.ip_forward/g" /etc/sysctl.conf
sh -c "echo 1 > /proc/sys/net/ipv4/ip_forward"
}

# configure dnsmaq

dnsmasq_config(){
echo -e "\n$GREEN Configuring dnsmasq" $RESETCOLOR
cp /etc/dnsmasq.conf /etc/dnsmasq.conf.bak
sleep 1

cat > /etc/dnsmasq.conf << EOL
interface=$wlan      						
listen-address=192.168.42.1					
bind-interfaces      				 
server=8.8.8.8       						
domain-needed        						
bogus-priv           						
dhcp-range=192.168.42.1,192.168.42.150,1200h 	
EOL
}
# replace torrc config

torrc_config(){
echo -e "\n$GREEN Upgrading your torrc file!" $RESETCOLOR
rm /etc/tor/torrc
cp torrc /etc/tor/torrc
sleep 1
}

# replace privoxy config

privoxy_conig(){
echo -e "\n$GREEN Upgrading privoxy config!" $RESETCOLOR
rm /etc/privoxy/config
cp config /etc/privoxy/config
sleep 1
}

# setting iptables to use tor 

set_iptables(){
echo -e "\n$GREEN Setting your iptables" $RESETCOLOR
eval "iptables -F"
eval "iptables -t nat -F"

eval "iptables -t nat -A POSTROUTING -o $eth -j MASQUERADE"
eval "iptables -A FORWARD -i $eth -o $wlan -m state --state RELATED,ESTABLISHED -j ACCEPT"
eval "iptables -A FORWARD -i $wlan -o $eth -j ACCEPT"
eval "iptables -t nat -A PREROUTING -i $wlan -p tcp --dport 22 -j REDIRECT --to-ports 22"
eval "iptables -t nat -A PREROUTING -i $wlan -p udp --dport 53 -j REDIRECT --to-ports 53"
eval "iptables -t nat -A PREROUTING -i $wlan -p tcp --syn -j REDIRECT --to-ports 9040"
eval "iptables -t nat -A PREROUTING -i $wlan -p tcp --syn -j REDIRECT --to-ports 9050"
sleep 1
}

# start tor

tor_start(){
echo -e "\n$RED Starting Tor" $RESETCOLOR
sleep 1
service tor stop
service tor start
echo -e "\n$GREEN Tor successfully configured and started" $RESETCOLOR
sleep 1
}

# privoxy start

privoxy_start(){
echo -e "\n$RED Starting Privoxy" $RESETCOLOR
sleep 1
service privoxy stop
service privoxy start
echo -e "\n$GREEN Privoxy successfully configured and started" $RESETCOLOR
sleep 1
}

restart_services(){

echo -e "\n$RED Restarting dhcpd" $RESETCOLOR
service isc-dhcp-server restart
sleep 1

echo -e "\n$GREEN reloading $wlan configuration" $RESETCOLOR
ifconfig $wlan down; ifconfig $wlan up
sleep 1

echo -e "\n$RED Restarting dnsmasq" $RESETCOLOR
/etc/init.d/dnsmasq restart
sleep 1
}

start_hotspot(){
echo -e "\n$GREEN Starting Str1k3 Tor Hotspot $RED ctrl+c to stop" $RESETCOLOR
sleep 1
#service hostapd start
service dnsmasq start
nmcli radio wifi off
rfkill unblock all
sleep 2
ifconfig $wlan 192.168.42.1
sleep 5
hostapd  /etc/hostapd/hostapd.conf 
#echo -n "\n[ctrl + c] to move process to background"
#echo -e "\n$YELLOW THIS WILL CONTINUE RUNNING IN THE BACKGROUND.... ENJOY!" $RESETCOLOR
sleep 3
}

stop_hotspot(){
echo -e "\n$YELLOW Stopping Str1k3 Tor Hotspot"
service tor stop
service hostapd stop
service dnsmasq stop
service privoxy stop
pkill hostapd
rm /etc/network/interfaces
cp /etc/network/interfaces.bak /etc/network/interfaces
rm /etc/default/isc-dhcp-server
cp /etc/default/isc-dhcp-server.bak /etc/default/isc-dhcp-server
rfkill unblock all
sleep 2
service networking restart
sleep 2
service NetworkManager restart
ifconfig $wlan up
}

# option check

# start
echo -e "\n$GREEN do you want start Str1k3 router or restore settings?$YELLOW Y $RED or $YELLOW N $RED or $YELLOW RESTORE  : " $RESETCOLOR
read answer
if [ $answer == "Y" ] || [ $answer == "y" ]
then
about
echo -e "\n$YELLOW Configuring Str1k3 Tor Hotspot...STAY An0nym0$ and FUCK the FBI hahaha " $RESETCOLOR
update
requirements
id_iface
set_ether
set_wifi
mac_eth0
mac_wlan0
edit_dhcpd
edit_isc_dhcp_server
Wlan_down
edit_interfaces
wlan_up
set_ssid
set_pass
cred_show
set_hostapd_conf
set_daemon
ipv4_forward
dnsmasq_config
torrc_config
privoxy_conig
set_iptables
tor_start
privoxy_start
restart_services
start_hotspot
elif [ $answer == "RESTORE" ] || [ $answer == "restore" ];then
stop_hotspot
id_iface
set_ether
set_wifi
ethmac_stop
wmac_stop
echo -e "\n$YELLOW *********THANKS FOR COMING!***********" $RESETCOLOR
else
echo -e "\n$YELLOW !!!!!!!!BYE!!!!!!!!" $RESETCOLOR
fi



