#!/bin/bash
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH

# Check if user is root
if [ $(id -u) != "0" ]; then
    echo "Error: You must be root to run this script, please use root to install vpnserver"
    exit 1
fi
clear
echo ""
echo -e "\033[7m"
echo "+---------------------------------------------------------------------+"    
echo "+                                                                     +"    
echo "+                     cobbler ks setting                              +"
echo "+                                                                     +"    
echo "+                     From ah.yangxiaofei@aisino.com                  +"    
echo "+                                                                     +"
echo "+                     Platform: CentOS                                +"    
echo "+                                                                     +"    
echo "+                     Data : 2018/01/02                        +"    
echo "+                                                                     +"    
echo "+---------------------------------------------------------------------+"
echo -e "\033[0m"
echo


###RHEL6 NETWORK STATIC SETTING##
el6()
{
/etc/init.d/network restart
Netcardname=`ip addr | grep '^[0-9]' |awk -F':' '{print $2}' |grep -v lo |sed 's/^[ \t]*//g'`
NetcatMAC=`ip addr |grep ether |awk '{print $2}'`
IP=`ifconfig |grep 'Bcast'  | awk -F ' ' '{print $2}' |awk -F ':' '{print $2}' |sed -n '1p'`
Netmask=`ifconfig -a|grep Mask |sed -n '1p' |awk -F':' '{print $4}'`
Gateway=`route  -n |grep UG|awk '{print $2}'`
DNS="192.168.202.250"

cat > /etc/sysconfig/network-scripts/ifcfg-$Netcardname <<EOF
DEVICE="${Netcardname}"
BOOTPROTO="static"
HWADDR="${NetcatMAC}"
IPADDR=${IP}
NETMASK=${Netmask}
GATEWAY=${Gateway}
DNS1=${DNS}
IPV6INIT="yes"
MTU="1500"
NM_CONTROLLED="yes"
ONBOOT="yes"
TYPE="Ethernet"
EOF
}


###RHEL7 NETWORK STATIC SETTING##
el7()
{
systemctl restart network.service
Netcardname=`ip addr | grep '^[0-9]' |awk -F':' '{print $2}' |grep -v lo |sed 's/^[ \t]*//g'`
NetcatMAC=`ip addr |grep ether |awk '{print $2}'|sed -n '1p'`
IP=`/usr/sbin/ifconfig |grep 'broadcast' |awk -F ' ' '{print $2}'|sed -n '1p'`
Netmask=`/usr/sbin/ifconfig -a |grep netmask |sed -n '1p' |awk '{print $4}'`
Gateway=`route  -n |grep UG|awk '{print $2}' |sed -n '1p'`
DNS="192.168.202.250"

cat > /etc/sysconfig/network-scripts/ifcfg-$Netcardname <<EOF
NAME="${Netcardname}"
DEVICE="${Netcardname}"
ONBOOT=yes
NETBOOT=yes
IPV6INIT=yes
BOOTPROTO=static
IPADDR=${IP}
NETMASK=${Netmask}
GATEWAY=${Gateway}
DNS1=${DNS}
TYPE=Ethernet
EOF
}


#Judgment system version
version=`cat /etc/redhat-release|sed -r 's/.* ([0-9]+)\..*/\1/'`
if [[ "${version}" = "6" ]];
then
	el6;	
elif [[ "${version}" = "7" ]];
then
	el7;
fi
