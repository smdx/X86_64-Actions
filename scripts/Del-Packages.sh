#!/bin/bash

# 移除要替换的包
rm -rf feeds/packages/net/smartdns
#rm -rf feeds/smpackage/smartdns
#rm -rf feeds/smpackage/luci-app-smartdns
rm -rf feeds/smpackage/adguardhome
rm -rf feeds/smpackage/luci-app-adguardhome
rm -rf feeds/smpackage/{base-files,dnsmasq,firewall*,fullconenat,libnftnl,nftables,ppp,opkg,ucl,upx,vsftpd-alt,miniupnpd-iptables,wireless-regdb}

echo -e "\e[31mDeletion of package completed\e[0m"
